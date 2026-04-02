import SwiftUI
import UIKit

public struct AuthView: View {
    @ObservedObject var appState: AppState
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.cream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        VStack(spacing: 8) {
                            Text("Layman")
                                .font(Theme.Typography.logoSmall)
                                .foregroundColor(Theme.Colors.accentOrange)
                                .padding(.top, 20)

                            Text("Welcome Back")
                                .font(Theme.Typography.title1)
                                .foregroundColor(Theme.Colors.darkText)

                            Text("Sign in to continue reading")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.subtleText)
                        }
                        .padding(.top, 40)

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
                                placeholder: "Password",
                                text: $viewModel.password,
                                isSecure: true,
                                keyboardType: .default,
                                isValid: true
                            )
                            .focused($focusedField, equals: .password)
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
                                viewModel.login { success in
                                    if success { appState.login() }
                                }
                            }) {
                                ZStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Log In")
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
                            .disabled(!viewModel.canLogin)
                            .opacity(viewModel.canLogin ? 1.0 : 0.6)

                            NavigationLink {
                                SignUpView(appState: appState)
                            } label: {
                                HStack(spacing: 4) {
                                    Text("New here?")
                                        .foregroundColor(Theme.Colors.subtleText)
                                    Text("Create an account")
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
                    default:
                        focusedField = nil
                        viewModel.login { success in
                            if success { appState.login() }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation { appState.currentScreen = .welcome }
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
        }
    }
}

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    let isValid: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(isValid ? Theme.Colors.accentOrange.opacity(0.7) : .red.opacity(0.7))
                .frame(width: 22)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .font(Theme.Typography.body)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Theme.Colors.beige.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isValid ? Color.clear : Color.red.opacity(0.4), lineWidth: 1)
        )
    }
}
