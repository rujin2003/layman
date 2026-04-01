import SwiftUI

public struct SavedView: View {
    @State private var savedArticles: [Article] = Article.mocks
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.cream.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack {
                            Text("Saved")
                                .font(Theme.Typography.title1)
                                .foregroundColor(Theme.Colors.darkText)
                            Spacer()
                            Button(action: { /* Search saved */ }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(Theme.Colors.darkText)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // List
                        if savedArticles.isEmpty {
                            VStack {
                                Spacer().frame(height: 100)
                                Image(systemName: "bookmark.slash")
                                    .font(.system(size: 64))
                                    .foregroundColor(Theme.Colors.beige)
                                Text("No saved articles yet.")
                                    .font(Theme.Typography.body)
                                    .foregroundColor(Theme.Colors.darkText.opacity(0.6))
                                    .padding(.top)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(savedArticles) { article in
                                    ArticleRow(article: article)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

#Preview {
    SavedView()
}
