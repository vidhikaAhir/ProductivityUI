import SwiftUI

struct AppGateView: View {
    @EnvironmentObject private var appSession: AppSession

    var body: some View {
        Group {
            if appSession.isLoggedIn {
                RootTabView()
            } else {
                LoginScreen()
            }
        }
    }
}
