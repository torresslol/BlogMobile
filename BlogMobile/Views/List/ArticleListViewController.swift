//
//  ArticleListViewController.swift
//  BlogMobile
//
//  Created by torresslol on 2024/12/28.
//

import UIKit
import IGListKit
import Kingfisher
import SnapKit
import Combine

class ArticleListViewController: UIViewController {
    // MARK: - Properties
    private let articleListBloc = ArticleListBloc(articleService: ArticleServiceImpl())
    private var cancellables = Set<AnyCancellable>()
    private var collectionView: UICollectionView!
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    // Loading Views
    private let refreshControl = UIRefreshControl()
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // State
    private var isLoadingMore = false
    private var currentPage = 1
    private var hasMoreData = true
    
    // Configuration
    private let pageSize = 20
    private let preloadThreshold = 0.7
    private var lastLoadMoreTime: TimeInterval = 0
    private let loadMoreThrottleInterval: TimeInterval = 0.5 // 500ms
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        setupLoadingIndicator()
        bindViewModel()
        fetchInitialData()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "Articles"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = .zero
        
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        collectionView.prefetchDataSource = self
        collectionView.showsVerticalScrollIndicator = false
        
        refreshControl.addTarget(
            self,
            action: #selector(refreshArticles),
            for: .valueChanged
        )
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        articleListBloc.articlesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] articles in
                guard let self = self else { return }
                if articles.isEmpty {
                    collectionView.backgroundView?.isHidden = false
                }
                self.hasMoreData = articles.count % self.pageSize == 0
                self.adapter.performUpdates(animated: true) { [weak self] completed in
                    guard let self = self else { return }
                    self.refreshControl.endRefreshing()
                    self.isLoadingMore = false
                    self.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        articleListBloc.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading && !self.refreshControl.isRefreshing {
                    self.isLoadingMore = true
                    self.loadingIndicator.startAnimating()
                    self.adapter.collectionView?.backgroundView?.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        articleListBloc.errorPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 } // Filter out nil values
            .sink { [weak self] error in
                guard let self = self else { return }
                
                self.refreshControl.endRefreshing()
                self.isLoadingMore = false
                self.loadingIndicator.stopAnimating()
                
                self.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading Methods
    private func fetchInitialData() {
        currentPage = 1
        fetchArticle(page: currentPage)
    }
    
    @objc private func refreshArticles() {
        currentPage = 1
        hasMoreData = true
        isLoadingMore = false
        loadingIndicator.stopAnimating()
        fetchArticle(page: currentPage)
    }
    
    private func loadMoreArticles() {
        guard !isLoadingMore && hasMoreData else { return }
        currentPage += 1
        fetchArticle(page: currentPage)
    }
    
    private func fetchArticle(page: Int) {
        Task {
            do {
                try await articleListBloc.fetchArticles(page: currentPage)
            } catch {
                // 处理错误，例如显示错误提示
                print("Error fetching articles: \(error)")
            }
        }
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        
        present(alert, animated: true)
    }
}

// MARK: - ListAdapterDataSource
extension ArticleListViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return articleListBloc.getArticles() as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ArticleSectionController(bloc: articleListBloc)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        if articleListBloc.getArticles().isEmpty {
            let emptyView = UIView()
            let label = UILabel()
            label.text = "No articles available"
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            
            emptyView.addSubview(label)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            return emptyView
        }
        return nil
    }
}

// MARK: - UIScrollViewDelegate
extension ArticleListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard hasMoreData && !isLoadingMore else { return }
        
        // Check if scrolling down
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        guard velocity < 0 else { return }
        
        // Check throttle time
        let currentTime = Date().timeIntervalSince1970
        guard currentTime - lastLoadMoreTime >= loadMoreThrottleInterval else {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        let scrollPercentage = (offsetY + frameHeight) / contentHeight
        if scrollPercentage >= preloadThreshold {
            lastLoadMoreTime = currentTime
            loadMoreArticles()
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension ArticleListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        // Get real data from IGListKit adapter
        let objects = adapter.objects()
        
        for indexPath in indexPaths {
            guard indexPath.section < objects.count,
                  let article = objects[indexPath.section] as? Article else {
                continue
            }
            
            if let imageUrl = URL(string: article.cover) {
                KingfisherManager.shared.retrieveImage(with: imageUrl) { _ in }
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cancelPrefetchingForItemsAt indexPaths: [IndexPath]
    ) {
        let objects = adapter.objects()
        
        for indexPath in indexPaths {
            guard indexPath.section < objects.count,
                  let article = objects[indexPath.section] as? Article else {
                continue
            }
            
            // Cancel image preloading
            if let imageUrl = URL(string: article.cover) {
                KingfisherManager.shared.downloader.cancel(url: imageUrl)
            }
        }
    }
}
