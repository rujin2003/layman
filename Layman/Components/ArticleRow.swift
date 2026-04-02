import SwiftUI

public struct ArticleRow: View {
    let article: Article
    var compact: Bool = false

    public var body: some View {
        HStack(spacing: 14) {
            Group {
                if let urlString = article.imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            fallbackThumb
                        default:
                            ZStack {
                                Theme.Colors.beige
                                ProgressView()
                                    .tint(Theme.Colors.accentOrange)
                                    .scaleEffect(0.7)
                            }
                        }
                    }
                } else {
                    fallbackThumb
                }
            }
            .frame(width: compact ? 72 : 86, height: compact ? 72 : 86)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 6) {
                Text(article.displayTitle)
                    .font(compact ? .system(size: 15, weight: .semibold) : Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.darkText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    if let src = article.sourceName ?? article.sourceID {
                        Text(src.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Theme.Colors.accentOrange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.Colors.accentOrange.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    if !article.formattedDate.isEmpty {
                        Text(article.formattedDate)
                            .font(Theme.Typography.small)
                            .foregroundColor(Theme.Colors.subtleText)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, compact ? 8 : 12)
    }

    private var fallbackThumb: some View {
        LinearGradient(
            colors: [Theme.Colors.peach.opacity(0.5), Theme.Colors.accentOrange.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "newspaper")
                .font(.system(size: 20))
                .foregroundColor(Theme.Colors.accentOrange.opacity(0.5))
        )
    }
}
