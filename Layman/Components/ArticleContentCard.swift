import SwiftUI

public struct ExactLinesModifier: ViewModifier {
    let lineCount: Int
    let lineHeight: CGFloat
    let font: Font

    public func body(content: Content) -> some View {
        content
            .font(font)
            .lineSpacing(lineHeight * 0.25)
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
    let cardIndex: Int

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Part \(cardIndex + 1) of 3")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.Colors.accentOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.accentOrange.opacity(0.1))
                    .clipShape(Capsule())

                Spacer()
            }

            Text(text)
                .enforceExactLines(count: 6, font: Theme.Typography.body, lineHeight: 24)
                .foregroundColor(Theme.Colors.darkText)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Theme.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.cardCornerRadius))
        .shadow(color: Theme.Colors.cardShadow, radius: 12, y: 4)
    }
}
