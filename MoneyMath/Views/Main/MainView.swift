import SwiftUI
import RazorpayAdsSdk

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    @State private var isRazorpayInitialized = false
    @State private var isInitializing = false
    @State private var initializationError: String?

    var body: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    Image(systemName: isRazorpayInitialized ? "checkmark.circle.fill" : "power.circle")
                        .foregroundStyle(isRazorpayInitialized ? Color.green : Color.blue)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Razorpay SDK").font(.headline)
                        Text(isRazorpayInitialized ? "Ready to load ads" : (isInitializing ? "Initializing…" : "Initialize to start testing"))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if isInitializing {
                        ProgressView()
                    } else if !isRazorpayInitialized {
                        Button("Initialize", action: initializeRazorpaySDK)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                    }
                }
                .padding(.vertical, 4)
                if let initializationError {
                    Text(initializationError).font(.footnote).foregroundStyle(.red)
                }
            }

            Section {
                Picker("Network", selection: Binding(get: { viewModel.selectedSdkType }, set: { viewModel.update($0) })) {
                    ForEach(viewModel.sdkTypes.flatMap { $0 }) { network in
                        Text(network.displayName).tag(network)
                    }
                }
                .pickerStyle(.menu)
                Picker("Ad format", selection: Binding(get: { viewModel.selectedAdType }, set: { viewModel.update($0) })) {
                    ForEach(viewModel.sdkAdTypes.flatMap { $0 }) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                .pickerStyle(.menu)
                if viewModel.showsNativeSize {
                    Picker("Native size", selection: $viewModel.nativeAdSize) {
                        ForEach(NativeAdSize.allCases) { size in
                            Text(size.title).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                }
            } header: {
                Text("Ad configuration")
            } footer: {
                if viewModel.showsNativeSize { Text(viewModel.nativeAdSize.detail) }
            }

            Section {
                ForEach(viewModel.selectedKeyIndexes, id: \.self) { index in
                    let key = "\(viewModel.selectedSdkType.rawValue)-\(viewModel.selectedAdType.rawValue)-\(index)"
                    Button { viewModel.select(key) } label: {
                        HStack(spacing: 12) {
                            Text(String(index))
                                .font(.caption.monospacedDigit().weight(.semibold))
                                .foregroundStyle(.blue)
                                .frame(width: 28, height: 28)
                                .background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 7))
                            Text(key.replacingOccurrences(of: "Adster", with: "Razorpay")).font(.subheadline).foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 4)
                            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 3)
                    }
                    .disabled(!isRazorpayInitialized)
                }
            } header: {
                HStack { Text("Placements"); Spacer(); Text("\(viewModel.selectedKeyIndexes.count)") }
            } footer: {
                Text(isRazorpayInitialized ? "Choose a placement to load an ad." : "Initialize the SDK to enable placements.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ad demo")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.isLinkClicked) {
            if let key = viewModel.selectedKey {
                if viewModel.selectedAdType == .nativeReward || viewModel.selectedAdType == .carouselNativeReward {
                    NativeRewardScratchView(viewModel: .init(key: key, isRazorpayInitialized: isRazorpayInitialized))
                } else {
                    AdView(viewModel: .init(key: key, isRazorpayInitialized: isRazorpayInitialized,
                                           nativeAdSize: viewModel.showsNativeSize ? viewModel.nativeAdSize : nil))
                }
            }
        }
    }

    private func initializeRazorpaySDK() {
        guard !isInitializing else { return }
        isInitializing = true
        initializationError = nil
        Razorpay.sharedInstance().start { status in
            DispatchQueue.main.async {
                isInitializing = false
                isRazorpayInitialized = status != nil
                initializationError = status == nil ? "Initialization failed. Please try again." : nil
            }
        }
    }
}

#Preview {
    NavigationStack { MainView(viewModel: .init()) }
}
