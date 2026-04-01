import SwiftUI
import UIKit

public struct ArticleDetailView: View {
    let article: Article
    var namespace: Namespace.ID
    @Binding var isShowing: Bool
    
    @State private var selectedCardIndex = 0
    @State private var showingChat = false
    
    public var body: some View {
        ZStack {
            Theme.Colors.cream.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Toolbar
                HStack {
                    Button(action: { close() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(Theme.Colors.darkText)
                            .padding()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: { /* Show safari view context */ }) {
                            Image(systemName: "link")
                        }
                        Button(action: { /* Save / Bookmark action */ }) {
                            Image(systemName: "bookmark")
                        }
                        Button(action: { /* Share action */ }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .font(.title2)
                    .foregroundColor(Theme.Colors.darkText)
                    .padding()
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Headline (Exactly 2 lines)
                        Text(article.title)
                            .enforceExactLines(count: 2, font: Theme.Typography.title1, lineHeight: 40)
                            .padding(.horizontal)
                        
                        // Hero Image with MatchedGeometry
                        Group {
                            if let urlString = article.imageURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle().fill(Theme.Colors.beige)
                                }
                            } else {
                                Theme.Colors.primaryGradient
                            }
                        }
                        .frame(height: 250)
                        .clipped()
                        .matchedGeometryEffect(id: "image-\(article.id)", in: namespace)
                        
                        // 3 Swipeable Cards Area
                        VStack {
                            TabView(selection: $selectedCardIndex) {
                                ForEach(Array(article.chunkedContent.enumerated()), id: \.offset) { index, chunk in
                                    ArticleContentCard(text: chunk)
                                        .tag(index)
                                        .padding(.horizontal, 24)
                                }
                            }
                            .frame(height: 200) // approx height for 6 lines plus padding
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            // Simple haptic on swipe
                            .onChange(of: selectedCardIndex) { _ in
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                            
                            // Custom UIPageControl style indicator
                            HStack(spacing: 8) {
                                ForEach(0..<article.chunkedContent.count, id: \.self) { index in
                                    Circle()
                                        .fill(selectedCardIndex == index ? Theme.Colors.accentOrange : Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                        .animation(.spring(), value: selectedCardIndex)
                                }
                            }
                            .padding(.top, 8)
                        }
                        
                        Spacer()
                            .frame(height: 100)
                    }
                }
            }
            
            // "Ask Layman" FAB overlay
            VStack {
                Spacer()
                Button(action: {
                    showingChat = true
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Ask Layman")
                            .font(Theme.Typography.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Metrics.largeCornerRadius)
                            .fill(Theme.Colors.primaryGradient)
                            .shadow(color: Theme.Colors.accentOrange.opacity(0.4), radius: 10, y: 5)
                            .background(.ultraThinMaterial)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .fullScreenCover(isPresented: $showingChat) {
            AskLaymanView(article: article, isPresented: $showingChat)
        }
    }
    
    private func close() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isShowing = false
        }
    }
}
