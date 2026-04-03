import SwiftUI
import UIKit

/// Full list of articles (used by Home "View All").
struct AllArticlesView: View {
    let articles: [Article]
    var onSelect: (Article) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.cream.ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(articles) { article in
                            ArticleRow(article: article, compact: true)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Theme.Colors.listRowSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .padding(.horizontal, 12)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    onSelect(article)
                                }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("All articles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.accentOrange)
                }
            }
        }
    }
}
