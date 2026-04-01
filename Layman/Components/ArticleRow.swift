import SwiftUI

public struct ArticleRow: View {
    let article: Article
    
    public var body: some View {
        HStack(alignment: .top, spacing: Theme.Metrics.padding) {
            // Thumbnail
            Group {
                if let urlString = article.imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle().fill(Theme.Colors.beige)
                            .overlay(ProgressView())
                    }
                } else {
                    Theme.Colors.primaryGradient
                }
            }
            .frame(width: 80, height: 80)
            .cornerRadius(Theme.Metrics.cornerRadius)
            
            // Headline
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.darkText)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let src = article.sourceID {
                    Text(src.uppercased())
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.accentOrange)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ArticleRow(article: .mock)
        .padding()
}
