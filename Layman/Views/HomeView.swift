import SwiftUI
import UIKit

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @Namespace private var animation
    
    // For navigation to detail
    @State private var selectedArticle: Article?
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.cream
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Header
                        HStack {
                            Text("Layman")
                                .font(Theme.Typography.title1)
                                .foregroundColor(Theme.Colors.darkText)
                            Spacer()
                            Button(action: {
                                // Search action
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(Theme.Colors.darkText)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        if viewModel.isLoading && viewModel.articles.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)
                        } else {
                            // Featured Carousel
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.featuredArticles) { article in
                                        GeometryReader { geo in
                                            let minX = geo.frame(in: .global).minX
                                            FeaturedArticleCard(
                                                article: article,
                                                geometryPosition: minX,
                                                matchedNamespace: animation
                                            )
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                    selectedArticle = article
                                                }
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            }
                                        }
                                        .frame(width: 320, height: 420)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Today's Picks
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Today's Picks")
                                        .font(Theme.Typography.title2)
                                        .foregroundColor(Theme.Colors.darkText)
                                    Spacer()
                                    Button("View All") { }
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.accentOrange)
                                }
                                .padding(.horizontal)
                                
                                ForEach(viewModel.todaysPicks) { article in
                                    ArticleRow(article: article)
                                        .padding(.horizontal)
                                        .onTapGesture {
                                            selectedArticle = article
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                }
                            }
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            // Transition using fullScreenCover or custom overlay for MatchedGeometry.
            // For simple implementation of App Store feel, NavigationLink with custom transition or an overlay ZStack is used.
            .overlay(
                ZStack {
                    if let article = selectedArticle {
                        ArticleDetailView(
                            article: article,
                            namespace: animation,
                            isShowing: Binding(
                                get: { selectedArticle != nil },
                                set: { if !$0 { selectedArticle = nil } }
                            )
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(2)
                    }
                }
            )
            .onAppear {
                if viewModel.articles.isEmpty {
                    viewModel.fetchArticles()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
