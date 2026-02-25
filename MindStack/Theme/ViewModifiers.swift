import SwiftUI

struct Glow: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.25), radius: radius * 1.8, x: 0, y: 0)
    }
}

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 18
    var strokeOpacity: CGFloat = 0.14

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(strokeOpacity), lineWidth: 1)
            )
    }
}

extension View {
    func glow(_ color: Color = AppColors.primary, radius: CGFloat = 12) -> some View {
        modifier(Glow(color: color, radius: radius))
    }

    func glassCard(cornerRadius: CGFloat = 18, strokeOpacity: CGFloat = 0.14) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, strokeOpacity: strokeOpacity))
    }
}

