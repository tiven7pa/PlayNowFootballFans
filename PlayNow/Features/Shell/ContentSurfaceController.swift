import UIKit
import WebKit

final class ContentSurfaceController: UIViewController {

    private let address: String
    private var contentView: WKWebView!
    private let spinner = UIActivityIndicatorView(style: .large)
    private var initialLoad = true

    init(address: String) {
        self.address = address
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .allButUpsideDown
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    override func loadView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        contentView = WKWebView(frame: .zero, configuration: configuration)
        contentView.navigationDelegate = self
        contentView.uiDelegate = self
        contentView.allowsBackForwardNavigationGestures = true
        contentView.scrollView.contentInsetAdjustmentBehavior = .never
        contentView.backgroundColor = .black
        contentView.isOpaque = false
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        loadResource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.apply(.allButUpsideDown, from: self)
    }

    private func loadResource() {
        guard let resource = URL(string: address) else { return }
        var request = URLRequest(url: resource)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        contentView.load(request)
    }
}

extension ContentSurfaceController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if initialLoad {
            spinner.startAnimating()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if initialLoad {
            spinner.stopAnimating()
            initialLoad = false
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if initialLoad {
            spinner.stopAnimating()
            initialLoad = false
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if initialLoad {
            spinner.stopAnimating()
            initialLoad = false
        }
    }
}

extension ContentSurfaceController: WKUIDelegate {

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let target = navigationAction.targetFrame, target.isMainFrame {
            return nil
        }
        webView.load(navigationAction.request)
        return nil
    }
}
