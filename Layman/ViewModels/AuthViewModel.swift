import Foundation
import Combine
import UIKit

public class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showConfirmationAlert = false

    var isEmailValid: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }

    var isPasswordValid: Bool {
        password.count >= 6
    }

    var canLogin: Bool {
        !email.isEmpty && !password.isEmpty && isEmailValid && !isLoading
    }

    var canSignUp: Bool {
        !email.isEmpty && !password.isEmpty && isEmailValid && isPasswordValid
            && !confirmPassword.isEmpty && confirmPassword == password && !isLoading
    }

    private let supabase = SupabaseService.shared

    func login(completion: @escaping (Bool) -> Void) {
        guard canLogin else {
            if email.isEmpty || password.isEmpty {
                errorMessage = "Please enter your email and password."
            } else if !isEmailValid {
                errorMessage = "Please enter a valid email address."
            }
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await supabase.signIn(email: email, password: password)
                self.isLoading = false
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                completion(true)
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                completion(false)
            }
        }
    }

    func signUp(completion: @escaping (Bool) -> Void) {
        guard canSignUp else {
            if email.isEmpty || password.isEmpty {
                errorMessage = "Please fill in all fields."
            } else if !isEmailValid {
                errorMessage = "Please enter a valid email address."
            } else if !isPasswordValid {
                errorMessage = "Password must be at least 6 characters."
            } else if confirmPassword != password {
                errorMessage = "Passwords do not match."
            }
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await supabase.signUp(email: email, password: password)
                self.isLoading = false
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                completion(true)
            } catch let error as AuthError where error.errorDescription == AuthError.confirmationRequired.errorDescription {
                self.isLoading = false
                self.showConfirmationAlert = true
                completion(false)
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                completion(false)
            }
        }
    }
}
