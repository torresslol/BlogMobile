// WebViewManager.swift

// WebViewManager.swift

import WebKit
import Foundation

final class WebViewManager {
    static let shared = WebViewManager()

    private let processPool = WKProcessPool()
    private let configuration: WKWebViewConfiguration
    private var cachedWebViews: [String: WKWebView] = [:] // Cache WebView by URL

    // MARK: - Initialization

    private init() {
        configuration = WKWebViewConfiguration()
        configuration.processPool = processPool // Share ProcessPool for cache
        configuration.allowsInlineMediaPlayback = true

        // Warm up a WebView
        warmUp()
    }

    // MARK: - WebView Management

    private func warmUp() {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        cachedWebViews["warmup"] = webView
    }

    func webView(for url: String) -> WKWebView {
        if let cachedWebView = cachedWebViews[url] {
            return cachedWebView
        }

        // Use warmup WebView if available
        if let warmupWebView = cachedWebViews["warmup"] {
            cachedWebViews.removeValue(forKey: "warmup")
            cachedWebViews[url] = warmupWebView
            return warmupWebView
        }

        // Create a new WebView
        let webView = WKWebView(frame: .zero, configuration: configuration)
        cachedWebViews[url] = webView
        return webView
    }

    // MARK: - Cache Management

    func clearCache() {
        cachedWebViews.removeAll()
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: .distantPast
        ) { }
    }
}