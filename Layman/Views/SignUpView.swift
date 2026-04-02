import SwiftUI
import UIKit

public struct SignUpView: View {
    @ObservedObject var appState: AppState
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss

    private enum Field { case email, password, confirm }

    public var body: some View {
        ZStack {
            Theme.Colors.cream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(Theme.Typography.title1)
                            .foregroundColor(Theme.Colors.darkText)

                        Text("Join Layman and start reading smarter")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.subtleText)
                    }
                    .padding(.top, 30)

                    VStack(spacing: 16) {
                        AuthTextField(
                            icon: "envelope.fill",
                            placeholder: "Email address",
                            text: $viewModel.email,
                            isSecure: false,
                            keyboardType: .emailAddress,
                            isValid: viewModel.email.isEmpty || viewModel.isEmailValid
                        )
                        .focused($focusedField, equals: .email)
                        .textInputAutocapitalization(.never)

                        if !viewModel.isEmailValid && !viewModel.email.isEmpty {
                            Text("Please enter a valid email address")
                                .font(Theme.Typography.small)
                                .foregroundColor(.red.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }

                        AuthTextField(
                            icon: "lock.fill",
                            placeholder: "Password (min 6 characters)",
                            text: $viewModel.password,
                            isSecure: true,
                            keyboardType: .default,
                            isValid: viewModel.password.isEmpty || viewModel.isPasswordValid
                        )
                        .focused($focusedField, equals: .password)
                        .textInputAutocapitalization(.never)

                        AuthTextField(
                            icon: "checkmark.lock.fill",
                            placeholder: "Confirm password",
                            text: $viewModel.confirmPassword,
                            isSecure: true,
                            keyboardType: .default,
                            isValid: viewModel.confirmPassword.isEmpty || viewModel.confirmPassword == viewModel.password
                        )
                        .focused($focusedField, equals: .confirm)
                        .textInputAutocapitalization(.never)

                        if let error = viewModel.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 14))
                                Text(error)
                                    .font(Theme.Typography.caption)
                            }
                            .foregroundColor(.red.opacity(0.8))
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(20)
                    .background(Theme.Colors.formCardFill)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.largeCornerRadius))
                    .shadow(color: Theme.Colors.cardShadow, radius: 20, y: 10)
                    .padding(.horizontal, Theme.Metrics.padding)

                    VStack(spacing: 16) {
                        Button(action: {
                            focusedField = nil
                            viewModel.signUp { success in
                                if success { appState.login() }
                            }
                        }) {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Create Account")
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Theme.Colors.buttonGradient)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.largeCornerRadius))
                            .shadow(color: Theme.Colors.accentOrange.opacity(0.3), radius: 12, y: 6)
                        }
                        .disabled(!viewModel.canSignUp)
                        .opacity(viewModel.canSignUp ? 1.0 : 0.6)

                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            dismiss()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Already have an account?")
                                    .foregroundColor(Theme.Colors.subtleText)
                                Text("Log in")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.Colors.accentOrange)
                            }
                            .font(Theme.Typography.body)
                        }
                    }
                    .padding(.horizontal, Theme.Metrics.padding)

                    Spacer(minLength: 40)
                }
            }
            .onSubmit {
                switch focusedField {
                case .email: focusedField = .password
                case .password: focusedField = .confirm
                default:
                    focusedField = nil
                    viewModel.signUp { success in
                        if success { appState.login() }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Colors.darkText)
                        .padding(8)
                        .background(Theme.Colors.beige)
                        .clipShape(Circle())
                }
            }
        }
        .alert("Check Your Email", isPresented: $viewModel.showConfirmationAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("We sent a confirmation link to your email. Please verify your account before signing in.")
        }
    }
}
