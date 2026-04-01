import SwiftUI

public struct ExactLinesModifier: ViewModifier {
    let lineCount: Int
    let lineHeight: CGFloat
    let font: Font
    
    public func body(content: Content) -> some View {
        content
            .font(font)
            .lineSpacing(lineHeight * 0.2) // typical line-height tweak
            .frame(height: lineHeight * CGFloat(lineCount), alignment: .top)
            .clipped()
            .lineLimit(lineCount)
    }
}

public extension View {
    func enforceExactLines(count: Int, font: Font, lineHeight: CGFloat) -> some View {
        self.modifier(ExactLinesModifier(lineCount: count, lineHeight: lineHeight, font: font))
    }
}

public struct ArticleContentCard: View {
    let text: String
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                // Exactly 6 lines at ~22 height each depending on font body sizes
                .enforceExactLines(count: 6, font: Theme.Typography.body, lineHeight: 22)
                .foregroundColor(Theme.Colors.darkText)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Theme.Colors.beige)
        .cornerRadius(Theme.Metrics.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}
