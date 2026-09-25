//
//  NativeRewardScratchView.swift
//  AdsDemoSwiftUI
//

import SwiftUI
import UIKit
import AdvergeAdsSdk

struct NativeRewardScratchView: View {
    @StateObject var viewModel: AdsViewModel
    @State private var statusText = "Scratch to reveal your coupon"
    @State private var didRequestNativeReward = false
    @State private var isOfferPresented = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    detailsView
                    scratchCard
                    revenueView
                    errorView
                    Spacer(minLength: 40)
                }
                .padding()
            }

            if isOfferPresented, let ad = viewModel.mediationNativeRewardAd {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isOfferPresented = false
                    }

                VStack(spacing: 0) {
                    NativeRewardOfferView(ad: ad)
                        .frame(maxWidth: .infinity)
                        .frame(height: 430)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(radius: 12)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .onReceive(viewModel.$mediationNativeRewardAd) { ad in
            if ad != nil {
                statusText = "Native reward ad loaded"
                isOfferPresented = true
            }
        }
        .onDisappear {
            viewModel.mediationNativeRewardAd?.destroy()
        }
    }

    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SDK Status")
                .font(.headline)
            Text(viewModel.isAdvergeInitialized ? "Adverge SDK is initialized" : "Adverge SDK not initialized")
                .font(.subheadline)
                .foregroundColor(viewModel.isAdvergeInitialized ? .green : .red)
                .padding(8)
                .background(viewModel.isAdvergeInitialized ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(6)
            Text("Selected key: \(viewModel.displayKey)")
                .font(.callout)
                .bold()
                .foregroundColor(.brown)
            Text("Placement: \(viewModel.placementKey)")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    private var scratchCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Scratch Card")
                .font(.title3)
                .bold()
            Text(statusText)
                .font(.subheadline)
                .foregroundColor(.secondary)

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.96, green: 0.98, blue: 1.0))
                VStack(spacing: 10) {
                    Text("COUPON UNLOCKED")
                        .font(.headline)
                    Text("ADVERGE-DEMO")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                ScratchOverlayView(
                    onScratchStarted: {
                        guard !didRequestNativeReward else { return }
                        didRequestNativeReward = true
                        statusText = "Loading native reward ad..."
                        viewModel.loadNativeRewardAd()
                    },
                    onRevealed: {
                        statusText = "Coupon unlocked"
                    }
                )
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    @ViewBuilder
    private var revenueView: some View {
        if let revenueMessage = viewModel.revenueMessage {
            Text(revenueMessage)
                .font(.footnote)
                .foregroundColor(.purple)
                .padding(8)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(6)
        }
    }

    @ViewBuilder
    private var errorView: some View {
        if let error = viewModel.error {
            Text("Error: \(error)")
                .font(.callout)
                .foregroundColor(.red)
        }
    }
}

private struct ScratchOverlayView: UIViewRepresentable {
    let onScratchStarted: () -> Void
    let onRevealed: () -> Void

    func makeUIView(context: Context) -> ScratchOverlayUIView {
        let view = ScratchOverlayUIView()
        view.onScratchStarted = onScratchStarted
        view.onRevealed = onRevealed
        return view
    }

    func updateUIView(_ uiView: ScratchOverlayUIView, context: Context) {
        uiView.onScratchStarted = onScratchStarted
        uiView.onRevealed = onRevealed
    }
}

private final class ScratchOverlayUIView: UIView {
    var onScratchStarted: (() -> Void)?
    var onRevealed: (() -> Void)?

    private let revealThreshold: CGFloat = 0.55
    private let sampleStep = 8
    private let coverColor = UIColor(red: 0.73, green: 0.75, blue: 0.80, alpha: 1.0)
    private var maskImage: UIImage?
    private var maskContext: CGContext?
    private var didStart = false
    private var didReveal = false
    private var lastPoint = CGPoint.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isOpaque = false
        backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0, maskImage == nil else { return }
        createMask()
    }

    override func draw(_ rect: CGRect) {
        maskImage?.draw(in: bounds)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !didReveal, let point = touches.first?.location(in: self) else { return }
        if !didStart {
            didStart = true
            onScratchStarted?()
        }
        lastPoint = point
        clearLine(from: point, to: point)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !didReveal, let point = touches.first?.location(in: self) else { return }
        clearLine(from: lastPoint, to: point)
        lastPoint = point
        revealIfNeeded()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !didReveal else { return }
        if let point = touches.first?.location(in: self) {
            clearLine(from: lastPoint, to: point)
        }
        revealIfNeeded()
    }

    private func createMask() {
        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        coverColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setNeedsDisplay()
    }

    private func clearLine(from start: CGPoint, to end: CGPoint) {
        guard let currentImage = maskImage else { return }
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        currentImage.draw(in: bounds)
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        path.lineWidth = 52
        path.lineCapStyle = .round
        UIColor.clear.setStroke()
        path.stroke(with: .clear, alpha: 1)
        maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setNeedsDisplay()
    }

    private func revealIfNeeded() {
        guard scratchPercent() >= revealThreshold else { return }
        didReveal = true
        maskImage = nil
        setNeedsDisplay()
        onRevealed?()
    }

    private func scratchPercent() -> CGFloat {
        guard let cgImage = maskImage?.cgImage,
              let data = cgImage.dataProvider?.data,
              let pointer = CFDataGetBytePtr(data) else {
            return didReveal ? 1 : 0
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = cgImage.bytesPerRow
        var transparent = 0
        var total = 0

        for y in stride(from: 0, to: height, by: sampleStep) {
            for x in stride(from: 0, to: width, by: sampleStep) {
                total += 1
                let offset = y * bytesPerRow + x * 4 + 3
                if pointer[offset] == 0 {
                    transparent += 1
                }
            }
        }

        return total == 0 ? 0 : CGFloat(transparent) / CGFloat(total)
    }
}

private struct NativeRewardOfferView: UIViewRepresentable {
    let ad: MediationNativeRewardAd

    func makeUIView(context: Context) -> UIView {
        NativeRewardOfferUIKitView(ad: ad)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

private final class NativeRewardOfferUIKitView: UIView {
    private let ad: MediationNativeRewardAd

    init(ad: MediationNativeRewardAd) {
        self.ad = ad
        super.init(frame: .zero)
        buildView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildView() {
        let adView = MediationNativeRewardAdView()
        adView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(adView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(stack)

        let header = UIStackView()
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 12

        let logoView = UIImageView()
        logoView.contentMode = .scaleAspectFill
        logoView.clipsToBounds = true
        logoView.backgroundColor = UIColor.systemGray5
        logoView.layer.cornerRadius = 24
        logoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoView.widthAnchor.constraint(equalToConstant: 48),
            logoView.heightAnchor.constraint(equalToConstant: 48)
        ])

        let titleStack = UIStackView()
        titleStack.axis = .vertical
        titleStack.spacing = 3

        let advertiser = UILabel()
        advertiser.text = firstNonEmpty(ad.advertiser, "Featured offer")
        advertiser.font = .systemFont(ofSize: 13)
        advertiser.textColor = .secondaryLabel

        let title = UILabel()
        title.text = firstNonEmpty(ad.headline, "Native Reward Offer")
        title.font = .boldSystemFont(ofSize: 18)
        title.numberOfLines = 2

        titleStack.addArrangedSubview(advertiser)
        titleStack.addArrangedSubview(title)
        header.addArrangedSubview(logoView)
        header.addArrangedSubview(titleStack)

        let mediaContainer = UIView()
        mediaContainer.backgroundColor = UIColor.systemGray6
        mediaContainer.layer.cornerRadius = 12
        mediaContainer.clipsToBounds = true
        mediaContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mediaContainer.heightAnchor.constraint(equalToConstant: 150)
        ])

        let body = UILabel()
        body.text = firstNonEmpty(ad.reward?.description, firstNonEmpty(ad.body, "1. Visit this link here\n2. Complete the offer details.\n3. The offer code will be automatically applied."))
        body.font = .systemFont(ofSize: 14)
        body.numberOfLines = 4

        let codeContainer = UIView()
        codeContainer.backgroundColor = UIColor.systemGray6
        codeContainer.layer.cornerRadius = 10
        codeContainer.translatesAutoresizingMaskIntoConstraints = false

        let code = UILabel()
        code.text = "Code: \(firstNonEmpty(ad.reward?.coupon?.code, "5648320653"))"
        code.font = .boldSystemFont(ofSize: 16)
        code.textColor = .label
        code.textAlignment = .center
        code.numberOfLines = 1
        code.translatesAutoresizingMaskIntoConstraints = false
        codeContainer.addSubview(code)

        NSLayoutConstraint.activate([
            code.leadingAnchor.constraint(equalTo: codeContainer.leadingAnchor, constant: 12),
            code.trailingAnchor.constraint(equalTo: codeContainer.trailingAnchor, constant: -12),
            code.topAnchor.constraint(equalTo: codeContainer.topAnchor, constant: 10),
            code.bottomAnchor.constraint(equalTo: codeContainer.bottomAnchor, constant: -10)
        ])

        let cta = UIButton(type: .system)
        cta.setTitle(firstNonEmpty(ad.callToAction, "Redeem now"), for: .normal)
        cta.titleLabel?.font = .boldSystemFont(ofSize: 16)
        cta.backgroundColor = .systemBlue
        cta.tintColor = .white
        cta.layer.cornerRadius = 10
        cta.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        stack.addArrangedSubview(header)
        stack.addArrangedSubview(mediaContainer)
        stack.addArrangedSubview(body)
        stack.addArrangedSubview(codeContainer)
        stack.addArrangedSubview(cta)

        NSLayoutConstraint.activate([
            adView.leadingAnchor.constraint(equalTo: leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: trailingAnchor),
            adView.topAnchor.constraint(equalTo: topAnchor),
            adView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: adView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -16)
        ])

        if let mediaView = ad.mediaView {
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            mediaContainer.addSubview(mediaView)
            NSLayoutConstraint.activate([
                mediaView.leadingAnchor.constraint(equalTo: mediaContainer.leadingAnchor),
                mediaView.trailingAnchor.constraint(equalTo: mediaContainer.trailingAnchor),
                mediaView.topAnchor.constraint(equalTo: mediaContainer.topAnchor),
                mediaView.bottomAnchor.constraint(equalTo: mediaContainer.bottomAnchor)
            ])
        }

        if let logo = ad.logo ?? ad.icon, let url = URL(string: logo) {
            loadImage(url: url, into: logoView)
        }

        adView.advertiserView = advertiser
        adView.headlineView = title
        adView.bodyView = body
        adView.ctaView = cta
        adView.logoView = logoView
        adView.mediaView = mediaContainer
        adView.setNativeRewardAd(nativeRewardAd: ad)
    }

    private func firstNonEmpty(_ value: String?, _ fallback: String) -> String {
        guard let value, !value.isEmpty else { return fallback }
        return value
    }

    private func loadImage(url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
}
