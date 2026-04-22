import SwiftUI

struct CalendarScreen: View {
    @StateObject private var viewModel: CalendarViewModel
    @State private var showNotifications = false
    @State private var editingTask: TaskItem?
    @State private var editingNote: NoteItem?
    let taskViewModel: TasksViewModel
    let noteViewModel: NotesViewModel
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar.current

    init(viewModel: CalendarViewModel, taskViewModel: TasksViewModel, noteViewModel: NotesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.taskViewModel = taskViewModel
        self.noteViewModel = noteViewModel
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    monthHeader
                    weekdayHeader
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.monthDays(), id: \.self) { date in
                            CalendarDayCell(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: viewModel.selectedDate),
                                isCurrentMonth: calendar.isDate(date, equalTo: viewModel.selectedDate, toGranularity: .month),
                                dots: indicatorColors(for: date)
                            )
                            .onTapGesture {
                                viewModel.selectedDate = date
                            }
                        }
                    }

                    Text("Today's Schedule")
                        .font(.title3.bold())

                    ForEach(viewModel.itemsForSelectedDate) { item in
                        CalendarAgendaRow(item: item) {
                            handleSelection(item)
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNotifications = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")

                            if viewModel.unviewedCount > 0 {
                                Text("\(min(viewModel.unviewedCount, 99))")
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Circle().fill(Color.red))
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: 1)
                                    )
                                    .offset(x: 8, y: -5)
                            }
                        }
                        .padding(.trailing, 2)
                    }
                }
            }
            .overlay {
                if viewModel.isLoading || taskViewModel.isLoading || noteViewModel.isLoading {
                    LoadingOverlayView("Updating calendar...")
                }
            }
        }
        .sheet(isPresented: $showNotifications) {
            CalendarNotificationsSheet(viewModel: viewModel)
        }
        .sheet(item: $editingTask) { task in
            TaskEditorSheet(mode: .edit(task)) { title, detail, dueDate, reminder, priority in
                var updated = task
                updated.title = title
                updated.detail = detail
                updated.dueDate = dueDate
                updated.hasReminder = reminder
                updated.priority = priority
                taskViewModel.updateTask(updated)
                viewModel.refresh()
            }
        }
        .sheet(item: $editingNote) { note in
            NoteEditorSheet(mode: .edit(note)) { title, body in
                noteViewModel.updateNote(note, title: title, body: body)
                viewModel.refresh()
            }
        }
        .onAppear {
            viewModel.refresh()
        }
    }

    private var monthHeader: some View {
        HStack {
            Text(viewModel.currentMonthTitle)
                .font(.title2.bold())
            Spacer()
            Button {
                shiftMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.bordered)

            Button {
                shiftMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.bordered)
        }
    }

    private var weekdayHeader: some View {
        let labels = calendar.shortStandaloneWeekdaySymbols
        return HStack {
            ForEach(labels, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func indicatorColors(for date: Date) -> [Color] {
        var colors: [Color] = []
        if !viewModel.taskDots(on: date).isEmpty { colors.append(AppTheme.task) }
        if !viewModel.noteDots(on: date).isEmpty { colors.append(AppTheme.note) }
        if !viewModel.habitDots(on: date).isEmpty { colors.append(AppTheme.habit) }
        return Array(colors.prefix(3))
    }

    private func shiftMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: viewModel.selectedDate) {
            viewModel.selectedDate = newDate
        }
    }

    private func handleSelection(_ item: CalendarFeedItem) {
        switch item.type {
        case let .task(task), let .reminder(task):
            editingTask = task
        case let .note(note):
            editingNote = note
        case .habit:
            break
        }
    }
}
