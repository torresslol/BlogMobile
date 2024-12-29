//
//  DetailViewController.swift
//  BlogMobile
//
//  Created by yy on 2024/12/26.
//

import UIKit
import WebKit

class ArticleDetailViewController: UIViewController {
    private let article: Article
    private lazy var webView: WKWebView = {
        let web = WebViewManager.shared.webView(for: article.detailUrl())
        return web
    }()
    private let navigationBar = CustomNavigationBar()
    var cardTransitionDelegate: CustomTransitionDelegate?
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWebContent()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup navigation bar
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44 + (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0))
        }
        
        navigationBar.setTitle(article.title)
        navigationBar.onBackButtonTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        // Setup WebView
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
    }
    
    private func loadWebContent() {
        guard let url = URL(string: article.detailUrl()) else { return }
        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad
        )
        webView.load(request)
    }
}
