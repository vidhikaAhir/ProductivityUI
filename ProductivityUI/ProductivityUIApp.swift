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
    @StateObject private var appSession = AppSession.shared

    var body: some Scene {
        WindowGroup {
            AppGateView()
                .environmentObject(appContainer)
                .environmentObject(appSession)
                .task {
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
