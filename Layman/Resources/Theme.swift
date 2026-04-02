import SwiftUI

public enum Theme {
    public enum Colors {
        public static let cream = Color(red: 253/255, green: 249/255, blue: 238/255)
        public static let beige = Color(red: 247/255, green: 243/255, blue: 232/255)
        public static let accentOrange = Color(red: 255/255, green: 115/255, blue: 0/255)
        public static let peach = Color(red: 255/255, green: 180/255, blue: 130/255)
        public static let warmPeach = Color(red: 255/255, green: 210/255, blue: 170/255)
        public static let darkText = Color(red: 30/255, green: 30/255, blue: 30/255)
        public static let lightText = Color(white: 0.95)
        public static let subtleText = Color(red: 120/255, green: 110/255, blue: 100/255)
        public static let cardWhite = Color(red: 255/255, green: 253/255, blue: 248/255)

        public static let primaryGradient = LinearGradient(
            gradient: Gradient(colors: [warmPeach, peach, accentOrange]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        public static let softGradient = LinearGradient(
            gradient: Gradient(colors: [cream, beige]),
            startPoint: .top,
            endPoint: .bottom
        )

        public static let buttonGradient = LinearGradient(
            gradient: Gradient(colors: [peach, accentOrange]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    public enum Typography {
        public static let logo = Font.system(size: 48, weight: .black, design: .rounded)
        public static let logoSmall = Font.system(size: 28, weight: .black, design: .rounded)
        public static let title1 = Font.system(size: 32, weight: .bold, design: .default)
        public static let title2 = Font.system(size: 24, weight: .bold, design: .default)
        public static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
        public static let headline = Font.system(size: 18, weight: .bold, design: .default)
        public static let body = Font.system(size: 16, weight: .regular, design: .default)
        public static let bodyMedium = Font.system(size: 16, weight: .medium, design: .default)
        public static let caption = Font.system(size: 13, weight: .medium, design: .default)
        public static let small = Font.system(size: 12, weight: .regular, design: .default)
    }

    public enum Metrics {
        public static let padding: CGFloat = 16
        public static let smallPadding: CGFloat = 8
        public static let largePadding: CGFloat = 24
        public static let cornerRadius: CGFloat = 16
        public static let largeCornerRadius: CGFloat = 24
        public static let cardCornerRadius: CGFloat = 20
    }
}
