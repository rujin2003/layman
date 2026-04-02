import SwiftUI
import UIKit

public struct ArticleDetailView: View {
    let article: Article
    @Binding var isShowing: Bool
    @EnvironmentObject private var appState: AppState

    @State private var selectedCardIndex = 0
    @State private var showingChat = false
    @State private var showingSafari = false
    @State private var isSaved = false
    @State private var appeared = false

    public var body: some View {
        ZStack {
            Theme.Colors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                toolbar
                    .padding(.top, 8)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        headline

                        heroImage

                        contentCards

                        Spacer().frame(height: 100)
                    }
                }
            }

            askLaymanButton
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) { appeared = true }
            isSaved = appState.isArticleSaved(article)
        }
        .fullScreenCover(isPresented: $showingChat) {
            AskLaymanView(article: article, isPresented: $showingChat)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showingSafari) {
            if let url = URL(string: article.link) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    appeared = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isShowing = false
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Colors.darkText)
                    .padding(10)
                    .background(Theme.Colors.beige)
                    .clipShape(Circle())
            }

            Spacer()

            HStack(spacing: 14) {
                Button {
                    showingSafari = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    toolbarIcon("link")
                }

                Button {
                    Task {
                        await appState.toggleSaveArticle(article)
                        isSaved.toggle()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                } label: {
                    toolbarIcon(isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isSaved ? Theme.Colors.accentOrange : Theme.Colors.darkText)
                }

                if let shareURL = URL(string: article.link) {
                    ShareLink(item: shareURL, subject: Text(article.title)) {
                        toolbarIcon("square.and.arrow.up")
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func toolbarIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Theme.Colors.darkText)
            .padding(10)
            .background(Theme.Colors.beige)
            .clipShape(Circle())
    }

    // MARK: - Headline

    private var headline: some View {
        Text(article.title)
            .font(.system(size: 26, weight: .bold))
            .foregroundColor(Theme.Colors.darkText)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.top, 8)
    }

    // MARK: - Hero Image

    private var heroImage: some View {
        Group {
            if let urlString = article.imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        imageFallback
                    default:
                        ZStack {
                            Theme.Colors.beige
                            ProgressView().tint(Theme.Colors.accentOrange)
                        }
                    }
                }
            } else {
                imageFallback
            }
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius))
        .padding(.horizontal, 20)
    }

    private var imageFallback: some View {
        Theme.Colors.primaryGradient
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.4))
            )
    }

    // MARK: - Content Cards

    private var contentCards: some View {
        VStack(spacing: 12) {
            TabView(selection: $selectedCardIndex) {
                ForEach(Array(article.chunkedContent.enumerated()), id: \.offset) { index, chunk in
                    ArticleContentCard(text: chunk, cardIndex: index)
                        .tag(index)
                        .padding(.horizontal, 20)
                }
            }
            .frame(height: 220)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: selectedCardIndex) { _, _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(selectedCardIndex == index ? Theme.Colors.accentOrange : Color.gray.opacity(0.25))
                        .frame(width: selectedCardIndex == index ? 20 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: selectedCardIndex)
                }
            }
        }
    }

    // MARK: - Ask Layman FAB

    private var askLaymanButton: some View {
        VStack {
            Spacer()
            Button {
                showingChat = true
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Ask Layman")
                        .font(Theme.Typography.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Theme.Colors.buttonGradient)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.largeCornerRadius))
                .shadow(color: Theme.Colors.accentOrange.opacity(0.35), radius: 14, y: 6)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
