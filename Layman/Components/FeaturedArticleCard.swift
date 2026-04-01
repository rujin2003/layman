import SwiftUI

public struct FeaturedArticleCard: View {
    let article: Article
    var geometryPosition: CGFloat? = 0 // Used for parallax effect if provided
    var matchedNamespace: Namespace.ID? = nil
    
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
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
                    // Fallback gradient matching theme
                    Theme.Colors.primaryGradient
                }
            }
            // Optional parallax modifier simply using offset relative to geo
            .offset(x: (geometryPosition ?? 0) * 0.1)
            .frame(width: 320, height: 420)
            .clipped()
            
            if let ns = matchedNamespace {
                Color.clear
                    .matchedGeometryEffect(id: "image-\(article.id)", in: ns)
            }
            
            // Bottom gradient overlay for readability
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
                startPoint: .bottom,
                endPoint: .center
            )
            .frame(width: 320, height: 420)
            
            // Headline Overlaid
            Text(article.title)
                .font(Theme.Typography.title2)
                .foregroundColor(.white)
                // Enforce exact 2 line truncation
                .lineLimit(2)
                .truncationMode(.tail)
                .padding(Theme.Metrics.padding)
                .padding(.bottom, 16)
                .shadow(color: .black.opacity(0.3), radius: 2)
        }
        .frame(width: 320, height: 420)
        .cornerRadius(Theme.Metrics.largeCornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}
