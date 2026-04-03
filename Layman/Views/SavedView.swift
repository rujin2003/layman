import SwiftUI
import UIKit

public struct SavedView: View {
    @EnvironmentObject private var appState: AppState
    @State private var savedArticles: [Article] = []
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var showSearch = false
    @State private var selectedArticle: Article?

    private var filteredArticles: [Article] {
        if searchText.isEmpty { return savedArticles }
        let query = searchText.lowercased()
        return savedArticles.filter {
            $0.title.lowercased().contains(query)
            || ($0.description?.lowercased().contains(query) ?? false)
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.cream.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection

                        if showSearch {
                            searchBar
                        }

                        if isLoading {
                            loadingView
                        } else if filteredArticles.isEmpty {
                            emptyView
                        } else {
                            articleList
                        }
                    }
                    .padding(.bottom, 100)
                }
                .refreshable { await loadSavedArticles() }

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
            .onAppear { Task { await loadSavedArticles() } }
            .onChange(of: appState.savedArticleIDs) { _, newIDs in
                savedArticles = savedArticles.filter { newIDs.contains($0.id) }
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Text("Saved")
                .font(Theme.Typography.title1)
                .foregroundColor(Theme.Colors.darkText)
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showSearch.toggle()
                    if !showSearch { searchText = "" }
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

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.Colors.subtleText)
            TextField("Search saved articles...", text: $searchText)
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

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Theme.Colors.accentOrange)
                .scaleEffect(1.1)
            Text("Loading saved articles...")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 50))
                .foregroundColor(Theme.Colors.subtleText.opacity(0.4))

            Text(searchText.isEmpty ? "No saved articles yet" : "No results found")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.darkText)

            Text(searchText.isEmpty
                 ? "Articles you bookmark will appear here"
                 : "Try a different search term")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private var articleList: some View {
        LazyVStack(spacing: 4) {
            ForEach(filteredArticles) { article in
                ArticleRow(article: article)
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

    private func loadSavedArticles() async {
        isLoading = savedArticles.isEmpty
        do {
            savedArticles = try await SupabaseService.shared.fetchSavedArticles()
        } catch {
            print("Failed to load saved articles: \(error)")
        }
        isLoading = false
    }
}
