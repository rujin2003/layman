import Foundation
import SwiftUI
import Combine

public enum AppScreen {
    case welcome
    case auth
    case main
}

public class AppState: ObservableObject {
    @Published public var currentScreen: AppScreen = .welcome
    @Published public var isLoggedIn: Bool = false {
        didSet {
            currentScreen = isLoggedIn ? .main : .welcome
        }
    }
    
    public init() {
        // Here we could check persistent storage (e.g., UserDefaults or Supabase session)
        // to decide if we should skip the welcome/auth screen.
    }
}
