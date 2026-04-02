import SwiftUI

public struct FeaturedArticleCard: View {
    let article: Article
    var width: CGFloat = 320

    private var height: CGFloat { width * 0.72 }

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let urlString = article.imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            fallbackGradient
                        default:
                            ZStack {
                                Theme.Colors.beige
                                ProgressView()
                                    .tint(Theme.Colors.accentOrange)
                            }
                        }
                    }
                } else {
                    fallbackGradient
                }
            }
            .frame(width: width, height: height)
            .clipped()

            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.7), .black.opacity(0.2), .clear]),
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: 8) {
                if let source = article.sourceName ?? article.sourceID {
                    Text(source.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }

                Text(article.displayTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.4), radius: 2)
            }
            .padding(Theme.Metrics.padding)
            .padding(.bottom, 4)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.cardCornerRadius))
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
    }

    private var fallbackGradient: some View {
        LinearGradient(
            colors: [Theme.Colors.peach, Theme.Colors.accentOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "newspaper.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
        )
    }
}
