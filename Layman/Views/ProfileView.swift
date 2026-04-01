import SwiftUI
import UIKit

public struct ProfileView: View {
    @ObservedObject var appState: AppState
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.cream.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    HStack {
                        Text("Profile")
                            .font(Theme.Typography.title1)
                            .foregroundColor(Theme.Colors.darkText)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // User Info Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("John Doe")
                            .font(Theme.Typography.title2)
                            .foregroundColor(Theme.Colors.darkText)
                        
                        Text("john.doe@example.com")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.darkText.opacity(0.6))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.Colors.beige)
                    .cornerRadius(Theme.Metrics.cornerRadius)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Actions
                    Button(action: {
                        // Sign out logic here, then update state
                        let generator = UIImpactFeedbackGenerator(style: .rigid)
                        generator.impactOccurred()
                        
                        withAnimation {
                            appState.isLoggedIn = false
                        }
                    }) {
                        Text("Sign Out")
                            .font(Theme.Typography.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(Theme.Metrics.largeCornerRadius)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120) // Give space for tab bar
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(appState: AppState())
    }
}
