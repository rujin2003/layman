import SwiftUI
import UIKit

public struct AskLaymanView: View {
    @StateObject private var viewModel: ChatViewModel
    @Binding var isPresented: Bool
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    public init(article: Article, isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(article: article))
        self._isPresented = isPresented
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .bottom).combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                }

                                if viewModel.isTyping {
                                    typingIndicator
                                        .id("TYPING")
                                        .transition(.opacity)
                                }
                            }
                            .padding(.vertical, 16)
                            .animation(.easeInOut(duration: 0.25), value: viewModel.messages.count)
                        }
                        .onChange(of: viewModel.messages.count) { _, _ in
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                        .onChange(of: viewModel.isTyping) { _, isTyping in
                            if isTyping {
                                withAnimation { proxy.scrollTo("TYPING", anchor: .bottom) }
                            }
                        }

                        if !viewModel.suggestions.isEmpty && viewModel.messages.count <= 2 {
                            suggestionChips
                                .padding(.bottom, 8)
                        }
                    }

                    inputBar
                }
            }
            .navigationTitle("Ask Layman")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.Colors.subtleText.opacity(0.5))
                    }
                }
            }
            .toolbarBackground(Theme.Colors.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Typing Indicator

    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.beige)
                        .frame(width: 30, height: 30)
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.Colors.accentOrange)
                }

                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Theme.Colors.subtleText.opacity(0.4))
                            .frame(width: 7, height: 7)
                            .offset(y: typingBounce(index: i))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Theme.Colors.messageBubble)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private func typingBounce(index: Int) -> CGFloat {
        let phase = Date().timeIntervalSince1970 * 3 + Double(index) * 0.4
        return CGFloat(sin(phase)) * 4
    }

    // MARK: - Suggestions

    private var suggestionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.suggestions, id: \.self) { suggestion in
                    Button {
                        viewModel.fetchResponse(for: suggestion)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Text(suggestion)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.Colors.accentOrange)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Theme.Colors.accentOrange.opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Theme.Colors.accentOrange.opacity(0.25), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button { } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.Colors.subtleText.opacity(0.5))
                    .padding(10)
            }

            TextField("Type your question...", text: $inputText)
                .font(Theme.Typography.body)
                .focused($isInputFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Theme.Colors.messageBubble)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onSubmit { sendMessage() }

            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Theme.Colors.subtleText.opacity(0.3)
                        : Theme.Colors.accentOrange)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        viewModel.fetchResponse(for: text)
        inputText = ""
    }
}

// MARK: - Message Bubble

public struct MessageBubble: View {
    let message: ChatMessage

    public var body: some View {
        HStack(alignment: .top) {
            if message.isUser {
                Spacer(minLength: 50)
                Text(message.text)
                    .font(Theme.Typography.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Theme.Colors.buttonGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .clipShape(
                        .rect(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: 18,
                            bottomTrailingRadius: 6,
                            topTrailingRadius: 18
                        )
                    )
            } else {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.beige)
                        .frame(width: 32, height: 32)
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Colors.accentOrange)
                }

                Text(message.text)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.darkText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Theme.Colors.messageBubble)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 6,
                            bottomLeadingRadius: 18,
                            bottomTrailingRadius: 18,
                            topTrailingRadius: 18
                        )
                    )
                    .shadow(color: Theme.Colors.cardShadow, radius: 4, y: 2)

                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, 16)
    }
}
