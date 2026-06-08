import SwiftUI

struct SplashView: View {
    @StateObject var viewModel: SplashViewModel
    let onOpenMain: () -> Void
    let onOpenShell: (String) -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.showOffline {
                VStack(spacing: 12) {
                    Text("No internet connection")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Enable internet and open the app again to continue.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0xB8B8B8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(32)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.4)
            }
        }
        .statusBarHidden(true)
        .onAppear { viewModel.start() }
        .onChange(of: viewModel.outcome) { outcome in
            switch outcome {
            case .main:
                onOpenMain()
            case .shell(let address):
                onOpenShell(address)
            case .none:
                break
            }
        }
    }
}
