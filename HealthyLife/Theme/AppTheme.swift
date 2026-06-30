import SwiftUI

enum AppTheme {
    static let primary = Color(red: 0.18, green: 0.49, blue: 0.20)       // #2E7D32
    static let secondary = Color(red: 0.40, green: 0.73, blue: 0.42)      // #66BB6A
    static let container = Color(red: 0.91, green: 0.96, blue: 0.91)    // #E8F5E9
    static let warning = Color(red: 1.0, green: 0.56, blue: 0.0)        // #FF8F00
    static let background = Color(red: 0.97, green: 0.98, blue: 0.97)  // #F8FBF8

    static let disclaimerBackground = Color(red: 1.0, green: 0.95, blue: 0.88)
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.primary.opacity(configuration.isPressed ? 0.85 : 1))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
