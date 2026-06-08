import UIKit
import SwiftUI

final class RootViewController: UIViewController {

    private let preferences = AppPreferences.shared
    private let gateway = RemoteGateway()
    private var current: UIViewController?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        current?.supportedInterfaceOrientations ?? .portrait
    }

    override var childForStatusBarHidden: UIViewController? {
        current
    }

    override var childForStatusBarStyle: UIViewController? {
        current
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        showSplash()
    }

    private func showSplash() {
        let viewModel = SplashViewModel(preferences: preferences, gateway: gateway)
        let root = SplashView(
            viewModel: viewModel,
            onOpenMain: { [weak self] in self?.showMain() },
            onOpenShell: { [weak self] address in self?.showShell(address) }
        )
        let host = PortraitHostingController(rootView: root)
        host.view.backgroundColor = .black
        setContent(host, orientation: .portrait)
    }

    private func showMain() {
        let root = MainTabView(
            onOpenNotice: { [weak self] in self?.openNotice() }
        )
        let host = PortraitHostingController(rootView: root)
        setContent(host, orientation: .portrait)
    }

    private func showShell(_ address: String) {
        let controller = ContentSurfaceController(address: address)
        setContent(controller, orientation: .allButUpsideDown)
    }

    private func openNotice() {
        let controller = NoticeSurfaceController(address: RemoteGateway.policyLink)
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .fullScreen
        present(navigation, animated: true)
    }

    private func setContent(_ controller: UIViewController, orientation: UIInterfaceOrientationMask) {
        if let current {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        addChild(controller)
        controller.view.frame = view.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        current = controller

        AppDelegate.apply(orientation, from: self)
        setNeedsStatusBarAppearanceUpdate()
    }
}
