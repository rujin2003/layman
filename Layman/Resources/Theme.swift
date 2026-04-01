import SwiftUI

public enum Theme {
    public enum Colors {
        public static let background = Color("Background") // fallback if we use asset catalog, but we'll define synthetically here
        public static let cream = Color(red: 253/255, green: 249/255, blue: 238/255) // #FDF9EE
        public static let beige = Color(red: 247/255, green: 243/255, blue: 232/255) // #F7F3E8
        public static let accentOrange = Color(red: 255/255, green: 115/255, blue: 0/255) // #FF7300
        public static let peach = Color(red: 255/255, green: 180/255, blue: 130/255) // Warm peach
        public static let darkText = Color(red: 30/255, green: 30/255, blue: 30/255) // High-contrast text
        public static let lightText = Color(white: 0.95)
        
        public static let primaryGradient = LinearGradient(
            gradient: Gradient(colors: [peach, accentOrange]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    public enum Typography {
        public static let logo = Font.system(size: 48, weight: .black, design: .rounded)
        public static let title1 = Font.system(size: 34, weight: .bold, design: .default)
        public static let title2 = Font.system(size: 28, weight: .bold, design: .default)
        public static let title3 = Font.system(size: 22, weight: .semibold, design: .default)
        public static let headline = Font.system(size: 20, weight: .bold, design: .default)
        public static let body = Font.system(size: 16, weight: .regular, design: .default) // 6 lines per card requirement
        public static let caption = Font.system(size: 14, weight: .medium, design: .default)
    }
    
    public enum Metrics {
        public static let padding: CGFloat = 16
        public static let cornerRadius: CGFloat = 20
        public static let largeCornerRadius: CGFloat = 30
    }
}
