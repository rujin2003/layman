import Foundation
import Combine
import UIKit

@MainActor
public class AuthViewModel: ObservableObject {
    @Published public var email = ""
    @Published public var password = ""
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    // In a real app, this would use SupabaseService.shared
    
    public init() {}
    
    public func login(completion: @escaping () -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulating network request for Supabase Auth
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            // Trigger haptic for success
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            completion()
        }
    }
    
    public func signUp(completion: @escaping () -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password to sign up."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulating network request for Supabase Auth
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            // Trigger haptic
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            completion()
        }
    }
}
