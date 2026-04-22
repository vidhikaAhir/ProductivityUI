//
//  ProductivityUIApp.swift
//  ProductivityUI
//
//  Created by neo on 4/20/26.
//

import SwiftUI

@main
struct ProductivityUIApp: App {
    @StateObject private var appContainer = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appContainer)
                .task {
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
