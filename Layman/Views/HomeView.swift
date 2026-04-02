import SwiftUI
import UIKit

public struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedArticle: Article?
    @State private var showSearch = false
    @State private var currentFeaturedIndex = 0

    private var screenWidth: CGFloat { UIScreen.main.bounds.width }
    private var cardWidth: CGFloat { screenWidth * 0.82 }

    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.cream.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        
                        if showSearch {
                            searchBar
                        }

                        if viewModel.isLoading && viewModel.articles.isEmpty {
                            loadingView
                        } else if let error = viewModel.errorMessage, viewModel.articles.isEmpty {
                            errorView(error)
                        } else {
                            featuredSection
                            todaysPicksSection
                        }
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }

                if let article = selectedArticle {
                    ArticleDetailView(
                        article: article,
                        isShowing: Binding(
                            get: { selectedArticle != nil },
                            set: { if !$0 { selectedArticle = nil } }
                        )
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
                }
            }
            .onAppear {
                if viewModel.articles.isEmpty {
                    viewModel.fetchArticles()
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("Layman")
                .font(Theme.Typography.logoSmall)
                .foregroundColor(Theme.Colors.darkText)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showSearch.toggle()
                    if !showSearch { viewModel.searchText = "" }
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.Colors.darkText)
                    .padding(10)
                    .background(Theme.Colors.beige)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.Colors.subtleText)
            TextField("Search articles, topics...", text: $viewModel.searchText)
                .font(Theme.Typography.body)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Theme.Colors.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.Colors.hairlineBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Featured Carousel

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.featuredArticles) { article in
                        FeaturedArticleCard(
                            article: article,
                            width: cardWidth
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                selectedArticle = article
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollTargetBehavior(.paging)

            HStack(spacing: 6) {
                ForEach(0..<min(viewModel.featuredArticles.count, 5), id: \.self) { index in
                    Circle()
                        .fill(index == currentFeaturedIndex ? Theme.Colors.accentOrange : Color.gray.opacity(0.25))
                        .frame(width: 7, height: 7)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Today's Picks

    private var todaysPicksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Today's Picks")
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.darkText)
                Spacer()
                Button("View All") { }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.Colors.accentOrange)
            }
            .padding(.horizontal, 20)

            LazyVStack(spacing: 4) {
                ForEach(viewModel.todaysPicks) { article in
                    ArticleRow(article: article, compact: true)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.listRowSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 12)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                selectedArticle = article
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                }
            }
        }
        .padding(.bottom, 100)
    }

    // MARK: - Loading & Error

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Theme.Colors.accentOrange)
                .scaleEffect(1.2)
            Text("Loading articles...")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundColor(Theme.Colors.subtleText)
            Text(message)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.subtleText)
                .multilineTextAlignment(.center)
            Button("Try Again") { viewModel.fetchArticles() }
                .font(Theme.Typography.bodyMedium)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Theme.Colors.accentOrange)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.horizontal, 32)
    }
}
