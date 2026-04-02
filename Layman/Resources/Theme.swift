import SwiftUI
import UIKit

public enum Theme {
    public enum Colors {
        private static func uiColor(light: UIColor, dark: UIColor) -> UIColor {
            UIColor { tc in
                tc.userInterfaceStyle == .dark ? dark : light
            }
        }

        private static func color(light: UIColor, dark: UIColor) -> Color {
            Color(uiColor: uiColor(light: light, dark: dark))
        }

        // MARK: - Surfaces

        public static var cream: Color {
            color(
                light: UIColor(red: 253/255, green: 249/255, blue: 238/255, alpha: 1),
                dark: UIColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1)
            )
        }

        public static var beige: Color {
            color(
                light: UIColor(red: 247/255, green: 243/255, blue: 232/255, alpha: 1),
                dark: UIColor(red: 0.14, green: 0.14, blue: 0.16, alpha: 1)
            )
        }

        public static var cardWhite: Color {
            color(
                light: UIColor(red: 255/255, green: 253/255, blue: 248/255, alpha: 1),
                dark: UIColor(red: 0.16, green: 0.16, blue: 0.19, alpha: 1)
            )
        }

        /// Auth / form card backgrounds
        public static var formCardFill: Color {
            color(
                light: UIColor.white.withAlphaComponent(0.72),
                dark: UIColor(white: 0.18, alpha: 0.85)
            )
        }

        /// Search fields, elevated inputs
        public static var elevatedSurface: Color {
            color(
                light: UIColor.white.withAlphaComponent(0.82),
                dark: UIColor(white: 0.2, alpha: 0.75)
            )
        }

        /// Article list row chips
        public static var listRowSurface: Color {
            color(
                light: UIColor.white.withAlphaComponent(0.62),
                dark: UIColor(white: 0.17, alpha: 0.65)
            )
        }

        /// Chat bubbles (assistant), text fields on bars
        public static var messageBubble: Color {
            color(
                light: .white,
                dark: UIColor(white: 0.22, alpha: 1)
            )
        }

        // MARK: - Text

        public static var darkText: Color {
            color(
                light: UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1),
                dark: UIColor(white: 0.95, alpha: 1)
            )
        }

        public static var subtleText: Color {
            color(
                light: UIColor(red: 120/255, green: 110/255, blue: 100/255, alpha: 1),
                dark: UIColor(white: 0.62, alpha: 1)
            )
        }

        public static let lightText = Color(white: 0.95)

        // MARK: - Brand

        public static let accentOrange = Color(red: 255/255, green: 115/255, blue: 0/255)

        public static var peach: Color {
            color(
                light: UIColor(red: 255/255, green: 180/255, blue: 130/255, alpha: 1),
                dark: UIColor(red: 0.55, green: 0.32, blue: 0.2, alpha: 1)
            )
        }

        public static var warmPeach: Color {
            color(
                light: UIColor(red: 255/255, green: 210/255, blue: 170/255, alpha: 1),
                dark: UIColor(red: 0.42, green: 0.22, blue: 0.16, alpha: 1)
            )
        }

        // MARK: - Strokes & shadows

        public static var hairlineBorder: Color {
            color(
                light: UIColor.black.withAlphaComponent(0.06),
                dark: UIColor.white.withAlphaComponent(0.08)
            )
        }

        public static var cardShadow: Color {
            color(
                light: UIColor.black.withAlphaComponent(0.08),
                dark: UIColor.black.withAlphaComponent(0.45)
            )
        }

        // MARK: - UIKit (tab bar, etc.)

        public static var creamUIColor: UIColor {
            uiColor(
                light: UIColor(red: 253/255, green: 249/255, blue: 238/255, alpha: 1),
                dark: UIColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1)
            )
        }

        public static var subtleTextUIColor: UIColor {
            uiColor(
                light: UIColor(red: 120/255, green: 110/255, blue: 100/255, alpha: 1),
                dark: UIColor(white: 0.62, alpha: 1)
            )
        }

        public static var accentOrangeUIColor: UIColor {
            UIColor(red: 255/255, green: 115/255, blue: 0/255, alpha: 1)
        }

        // MARK: - Gradients

        public static var primaryGradient: LinearGradient {
            LinearGradient(
                colors: [
                    Color(uiColor: uiColor(
                        light: UIColor(red: 255/255, green: 210/255, blue: 170/255, alpha: 1),
                        dark: UIColor(red: 0.38, green: 0.2, blue: 0.14, alpha: 1)
                    )),
                    Color(uiColor: uiColor(
                        light: UIColor(red: 255/255, green: 180/255, blue: 130/255, alpha: 1),
                        dark: UIColor(red: 0.32, green: 0.16, blue: 0.12, alpha: 1)
                    )),
                    Color(uiColor: uiColor(
                        light: UIColor(red: 255/255, green: 115/255, blue: 0/255, alpha: 1),
                        dark: UIColor(red: 0.55, green: 0.28, blue: 0.1, alpha: 1)
                    ))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        public static var softGradient: LinearGradient {
            LinearGradient(
                colors: [cream, beige],
                startPoint: .top,
                endPoint: .bottom
            )
        }

        public static var buttonGradient: LinearGradient {
            LinearGradient(
                colors: [peach, accentOrange],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
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
