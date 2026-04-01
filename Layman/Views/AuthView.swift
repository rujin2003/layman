import SwiftUI

public struct AuthView: View {
    @ObservedObject var appState: AppState
    @StateObject private var viewModel = AuthViewModel()
    
    public var body: some View {
        ZStack {
            Theme.Colors.cream
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("Welcome Back")
                        .font(Theme.Typography.title1)
                        .foregroundColor(Theme.Colors.darkText)
                    
                    Text("Sign in to continue reading")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.darkText.opacity(0.6))
                }
                .padding(.top, 60)
                
                // Form
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Theme.Colors.beige)
                        .cornerRadius(Theme.Metrics.cornerRadius)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Theme.Colors.beige)
                        .cornerRadius(Theme.Metrics.cornerRadius)
                }
                .padding(.horizontal, Theme.Metrics.padding)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(Theme.Typography.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Actions
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.login {
                            appState.isLoggedIn = true
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.Colors.primaryGradient)
                                .cornerRadius(Theme.Metrics.largeCornerRadius)
                        } else {
                            Text("Log In")
                                .font(Theme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.Colors.primaryGradient)
                                .cornerRadius(Theme.Metrics.largeCornerRadius)
                        }
                    }
                    .disabled(viewModel.isLoading)
                    
                    Button(action: {
                        viewModel.signUp {
                            appState.isLoggedIn = true
                        }
                    }) {
                        Text("Don't have an account? Sign Up")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.accentOrange)
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, Theme.Metrics.padding)
                
                Spacer()
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(appState: AppState())
    }
}
