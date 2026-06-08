import UIKit
import WebKit
import SwiftUI

final class NoticeSurfaceController: UIViewController {

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
        .portrait
    }

    override func loadView() {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        contentView = WKWebView(frame: .zero, configuration: configuration)
        contentView.navigationDelegate = self
        contentView.scrollView.contentInsetAdjustmentBehavior = .never
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        title = "Privacy Policy"
        navigationController?.navigationBar.tintColor = UIColor(AppPalette.accentDark)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        spinner.color = .gray
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
        AppDelegate.apply(.portrait, from: self)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func loadResource() {
        guard let resource = URL(string: address) else { return }
        var request = URLRequest(url: resource)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        contentView.load(request)
    }
}

extension NoticeSurfaceController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if initialLoad { spinner.startAnimating() }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isOpaque = true
        webView.backgroundColor = .white
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
