import SwiftUI

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
                            VStack(spacing: 16) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                                
                                if viewModel.isTyping {
                                    HStack {
                                        // Simple typing indicator
                                        Image(systemName: "ellipsis")
                                            .foregroundColor(Theme.Colors.darkText.opacity(0.5))
                                            .padding()
                                            .background(Color.white)
                                            .clipShape(Capsule())
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .id("TYPING_INDICATOR")
                                    .transition(.opacity)
                                }
                            }
                            .padding(.vertical)
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                        .onChange(of: viewModel.isTyping) { isTyping in
                            if isTyping {
                                withAnimation {
                                    proxy.scrollTo("TYPING_INDICATOR", anchor: .bottom)
                                }
                            }
                        }
                      
                        if viewModel.messages.count == 1 {
                            SuggestionChips(suggestions: viewModel.suggestions) { suggestion in
                                viewModel.fetchResponse(for: suggestion)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                    
                    // Input bar (Ultra thin material)
                    HStack(spacing: 12) {
                        Button(action: { /* Mic Placeholder */ }) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.Colors.darkText.opacity(0.5))
                        }
                        
                        TextField("Type your question...", text: $inputText)
                            .focused($isInputFocused)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(20)
                            .onSubmit {
                                sendMessage()
                            }
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(inputText.isEmpty ? Theme.Colors.darkText.opacity(0.3) : Theme.Colors.accentOrange)
                        }
                        .disabled(inputText.isEmpty)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Ask Layman")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.Colors.darkText.opacity(0.5))
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        viewModel.fetchResponse(for: inputText)
        inputText = ""
    }
}

public struct MessageBubble: View {
    let message: ChatMessage
    
    public var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .font(Theme.Typography.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(Theme.Colors.primaryGradient)
                    // Glassmorphism feel on user bubble maybe? Just standard gradient here.
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                HStack(alignment: .top) {
                    // Bot Icon
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
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

public struct SuggestionChips: View {
    let suggestions: [String]
    let action: (String) -> Void
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(action: { action(suggestion) }) {
                        Text(suggestion)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.accentOrange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Theme.Colors.accentOrange.opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Theme.Colors.accentOrange.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
