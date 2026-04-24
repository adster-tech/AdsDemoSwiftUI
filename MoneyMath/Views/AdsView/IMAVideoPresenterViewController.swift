//
//  IMAVideoPresenterViewController.swift
//  AdsDemoSwiftUI
//
//  Hosts an IMA `MediationVideoAd` full-screen and drives its lifecycle:
//    1. Creates a container view the ad attaches into.
//    2. Calls `attach(to:)` and `showAd(from:)` after the container is on-screen
//       so the IMA SDK has a valid hosting view controller.
//    3. Auto-dismisses when the ad completes / is skipped, or when the user
//       taps the "Close" button.
//

import UIKit
import AdsFramework

final class IMAVideoPresenterViewController: UIViewController {

    private let videoAd: MediationVideoAd
    private let onDismiss: (() -> Void)?
    private var didStartAd = false

    private let adContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(white: 0, alpha: 0.4)
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(onCloseTapped), for: .touchUpInside)
        return b
    }()

    init(videoAd: MediationVideoAd, onDismiss: (() -> Void)? = nil) {
        self.videoAd = videoAd
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        view.addSubview(adContainer)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            adContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            adContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            adContainer.topAnchor.constraint(equalTo: view.topAnchor),
            adContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
        ])

        // Attach the ad *before* the view appears so IMA can lay its ad UI out
        // at the correct size on first render.
        videoAd.attach(to: adContainer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start playback once we're definitely on-screen with a live view-controller
        // context (required for IMA click-through overlays).
        if !didStartAd {
            didStartAd = true
            videoAd.showAd(from: self)
        }
    }

    override var prefersStatusBarHidden: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .landscape]
    }

    // MARK: - Events

    /// Called by the view-model when the IMA delegate fires COMPLETE / SKIPPED /
    /// ALL_ADS_COMPLETED. Auto-dismisses the full-screen presentation.
    func adDidComplete() {
        dismissSelf()
    }

    @objc private func onCloseTapped() {
        dismissSelf()
    }

    private func dismissSelf() {
        guard presentingViewController != nil else { return }
        videoAd.destroy()
        let done = onDismiss
        dismiss(animated: true) {
            done?()
        }
    }
}
