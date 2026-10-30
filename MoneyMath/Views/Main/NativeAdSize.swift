import SwiftUI

/// Matches the Android demo's native presentation choices (points on iOS).
enum NativeAdSize: String, CaseIterable, Identifiable {
    case small, medium, big, square, fullscreen
    var id: String { rawValue }
    var title: String { rawValue == "fullscreen" ? "Fullscreen" : rawValue.capitalized }
    var detail: String {
        switch self {
        case .small: return "Compact row · 140 pt media"
        case .medium: return "180 pt media above the details"
        case .big: return "280 pt media above the details"
        case .square: return "Square media above the details"
        case .fullscreen: return "Full screen with a Close button"
        }
    }
    var mediaHeight: CGFloat? {
        switch self {
        case .small: return 140
        case .medium: return 180
        case .big: return 280
        case .square, .fullscreen: return nil
        }
    }
}

/// The small template allocates 36% of the row to media, as Android does.
struct NativeCompactLayout: Layout {
    private let spacing: CGFloat = 12
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width.flatMap { $0.isFinite ? max(0, $0) : nil } ?? 320
        guard subviews.count == 2 else {
            return subviews.first?.sizeThatFits(ProposedViewSize(width: width, height: nil)) ?? .zero
        }
        let mediaWidth = max(0, width - spacing) * 0.36
        let details = subviews[1].sizeThatFits(ProposedViewSize(width: max(0, width - spacing - mediaWidth), height: nil))
        return CGSize(width: width, height: max(140, details.height))
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 2 else {
            subviews.first?.place(at: bounds.origin, proposal: ProposedViewSize(bounds.size))
            return
        }
        let mediaWidth = max(0, bounds.width - spacing) * 0.36
        subviews[0].place(at: CGPoint(x: bounds.minX, y: bounds.midY - 70), proposal: ProposedViewSize(width: mediaWidth, height: 140))
        let detailWidth = max(0, bounds.width - spacing - mediaWidth)
        let details = subviews[1].sizeThatFits(ProposedViewSize(width: detailWidth, height: nil))
        subviews[1].place(at: CGPoint(x: bounds.minX + mediaWidth + spacing, y: bounds.midY - details.height / 2), proposal: ProposedViewSize(width: detailWidth, height: details.height))
    }
}

struct NativeMediaSizing: ViewModifier {
    let size: NativeAdSize?
    var defaultRatio: CGFloat = 16.0 / 9.0
    @ViewBuilder func body(content: Content) -> some View {
        switch size {
        case .small, .medium, .big:
            content.frame(maxWidth: .infinity).frame(height: size?.mediaHeight)
        case .square:
            content.aspectRatio(1, contentMode: .fit)
        case .fullscreen:
            content.frame(maxWidth: .infinity, maxHeight: .infinity)
        case nil:
            content.aspectRatio(defaultRatio, contentMode: .fit)
        }
    }
}
