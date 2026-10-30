import SwiftUI
import AdsFramework

/// A content-sized, media-first native card shared by single and carousel ads.
struct NativeAdView: View {
    let ad: MediationNativeAd
    var size: NativeAdSize? = nil

    var body: some View {
        NativeAdCard(ad: ad, size: size)
            .id(ObjectIdentifier(ad))
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
            .padding(.horizontal, 12)
    }
}

private struct NativeAdCard: UIViewRepresentable {
    let ad: MediationNativeAd
    let size: NativeAdSize?

    func makeUIView(context: Context) -> MediationNativeAdView {
        let root = MediationNativeAdView()
        let content = UIStackView()
        content.axis = size == .small ? .horizontal : .vertical
        content.alignment = size == .small ? .center : .fill
        content.spacing = 12
        content.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            content.topAnchor.constraint(equalTo: root.topAnchor),
            content.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])

        if let media = ad.mediaView {
            let viewport = UIView()
            viewport.clipsToBounds = true
            content.addArrangedSubview(viewport)
            switch size {
            case .small:
                viewport.widthAnchor.constraint(equalTo: root.widthAnchor, multiplier: 0.36, constant: -4.32).isActive = true
                viewport.heightAnchor.constraint(equalToConstant: 140).isActive = true
            case .medium, .big:
                viewport.heightAnchor.constraint(equalToConstant: size?.mediaHeight ?? 280).isActive = true
            case .square:
                viewport.heightAnchor.constraint(equalTo: viewport.widthAnchor).isActive = true
            case .fullscreen:
                viewport.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
                viewport.setContentHuggingPriority(.defaultLow, for: .vertical)
            case nil:
                let ratio = ad.videoController != nil ? 16.0 / 9.0 : (ad.aspectRatio ?? 16.0 / 9.0)
                viewport.heightAnchor.constraint(equalTo: viewport.widthAnchor, multiplier: 1 / (ratio.isFinite && ratio > 0 ? ratio : 16.0 / 9.0)).isActive = true
            }
            embedAdMedia(media, in: viewport)
            root.mediaView = viewport
        }

        let footer = UIView()
        content.addArrangedSubview(footer)
        let row = UIStackView()
        row.axis = size == nil ? .horizontal : .vertical
        row.alignment = size == nil ? .center : .fill
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -12),
            row.topAnchor.constraint(equalTo: footer.topAnchor, constant: ad.mediaView == nil || size == .small ? 12 : 0),
            row.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -12)
        ])
        let text = UIStackView()
        text.axis = .vertical
        text.spacing = 4
        row.addArrangedSubview(text)
        let attribution = label("Ad", style: .caption2)
        attribution.textColor = .secondaryLabel
        text.addArrangedSubview(attribution)
        let headline = label(ad.headline, style: .headline)
        headline.numberOfLines = size == nil ? 0 : 2
        text.addArrangedSubview(headline)
        let body = label(ad.body, style: .footnote)
        body.numberOfLines = size == nil ? 0 : 2
        text.addArrangedSubview(body)
        root.headlineView = headline
        root.bodyView = body

        if let title = ad.callToAction, !title.isEmpty {
            let cta = UIButton(type: .system)
            var configuration = UIButton.Configuration.filled()
            configuration.title = title
            configuration.cornerStyle = .medium
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
            cta.configuration = configuration
            cta.titleLabel?.numberOfLines = 2
            cta.titleLabel?.textAlignment = .center
            cta.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
            if size == nil { cta.widthAnchor.constraint(lessThanOrEqualToConstant: 140).isActive = true }
            row.addArrangedSubview(cta)
            root.ctaView = cta
        }
        // Register the full card and all clickable assets once, including media.
        // SDK gesture filtering leaves video playback controls independent of ad clicks.
        root.setNativeAd(nativeAd: ad)
        return root
    }

    func updateUIView(_ uiView: MediationNativeAdView, context: Context) {}

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: MediationNativeAdView, context: Context) -> CGSize? {
        guard let width = proposal.width, width > 0 else { return nil }
        if size == .fullscreen, let height = proposal.height, height.isFinite {
            return CGSize(width: width, height: height)
        }
        return uiView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }

    private func label(_ text: String?, style: UIFont.TextStyle) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.isHidden = text?.isEmpty != false
        return label
    }
}

/// Mount SDK-owned UIKit media without recreating its player on SwiftUI updates.
struct EmbeddedAdMediaView: UIViewRepresentable {
    let media: UIView

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.clipsToBounds = true
        embedAdMedia(media, in: container)
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if media.superview !== uiView {
            uiView.subviews.forEach { $0.removeFromSuperview() }
            embedAdMedia(media, in: uiView)
        }
    }
}

private func embedAdMedia(_ media: UIView, in container: UIView) {
    media.removeFromSuperview()
    media.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(media)
    NSLayoutConstraint.activate([
        media.leadingAnchor.constraint(equalTo: container.leadingAnchor),
        media.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        media.topAnchor.constraint(equalTo: container.topAnchor),
        media.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])
}
