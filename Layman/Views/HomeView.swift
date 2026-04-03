import SwiftUI
import UIKit

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedArticle: Article?
    @State private var showSearch = false
    @State private var showAllArticles = false
    @State private var headerAppeared = false

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
                                .transition(.move(edge: .top).combined(with: .opacity))
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
                .animation(.spring(response: 0.38, dampingFraction: 0.86), value: showSearch)
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
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .zIndex(2)
                }
            }
            .onAppear {
                if viewModel.articles.isEmpty {
                    viewModel.fetchArticles()
                }
                withAnimation(.easeOut(duration: 0.45).delay(0.05)) {
                    headerAppeared = true
                }
            }
            .sheet(isPresented: $showAllArticles) {
                AllArticlesView(articles: viewModel.filteredArticles) { article in
                    showAllArticles = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            selectedArticle = article
                        }
                    }
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
                .offset(y: headerAppeared ? 0 : -8)
                .opacity(headerAppeared ? 1 : 0)

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
            .buttonStyle(PressableScaleStyle(scale: 0.92))
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
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showAllArticles = true
                } label: {
                    Text("View All")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.Colors.accentOrange)
                }
                .buttonStyle(PressableScaleStyle(scale: 0.94))
            }
            .padding(.horizontal, 20)

            LazyVStack(spacing: 4) {
                ForEach(Array(viewModel.todaysPicks.enumerated()), id: \.element.id) { index, article in
                    ArticleRow(article: article, compact: true)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.listRowSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 12)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                selectedArticle = article
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .animation(.easeOut(duration: 0.35), value: viewModel.todaysPicks.map(\.id))
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
                .buttonStyle(PressableScaleStyle(scale: 0.95))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.horizontal, 32)
    }
}
