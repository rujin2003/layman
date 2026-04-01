//
//  LaymanApp.swift
//  Layman
//
//  Created by Rujin Devkota on 01/04/26.
//

import SwiftUI

@main
struct LaymanApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appState.currentScreen {
                case .welcome:
                    WelcomeView(appState: appState)
                case .auth:
                    AuthView(appState: appState)
                case .main:
                    MainTabView(appState: appState)
                }
            }
            .environmentObject(appState)
        }
    }
}
