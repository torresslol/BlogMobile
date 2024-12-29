import Foundation
import Moya
import Combine

class ArticleListBloc {
    private let articleService: ArticleService
    private var layoutCache: [String: ArticleLayoutCache] = [:]
    private let screenWidth = UIScreen.main.bounds.width
    
    // MARK: - Subjects
    private let articlesSubject = CurrentValueSubject<[Article], Never>([])
    private let loadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<Error?, Never>(nil)
    
    // MARK: - Publishers
    var articlesPublisher: AnyPublisher<[Article], Never> {
        articlesSubject.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        loadingSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<Error?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    init(articleService: ArticleService) {
        self.articleService = articleService
    }
    
    deinit {
        layoutCache.removeAll()
    }
    
    // MARK: - Article Management
    func getArticles() -> [Article] {
        return articlesSubject.value
    }
    
    func fetchArticles(page: Int = 1, size: Int = 20, locale: String = "en") async throws {
        await setLoading(true)
        
        do {
            // Use the service to get articles
            let articles = try await articleService.getArticles(page: page, size: size, locale: locale)
            
            // Assuming calculateLayoutsForNewArticles and updateArticles are defined methods
            calculateLayoutsForNewArticles(articles)
            await updateArticles(articles, forPage: page)
            
        } catch {
            await setError(error)
        }
        
        await setLoading(false)
    }
    
    // MARK: - Layout Calculation
    private func calculateLayoutsForNewArticles(_ newArticles: [Article]) {
        for article in newArticles {
            let cacheKey = "\(article.id)_\(screenWidth)"
            if layoutCache[cacheKey] == nil {
                layoutCache[cacheKey] = ArticleLayoutCache.calculate(
                    for: article,
                    width: screenWidth
                )
            }
        }
    }
    
    // MARK: - Loading and Error Handling
    @MainActor
    private func setLoading(_ loading: Bool) {
        loadingSubject.send(loading)
    }
    
    @MainActor
    private func setError(_ error: Error) {
        errorSubject.send(error)
    }
    
    // MARK: - Article Update
    @MainActor
    private func updateArticles(_ newArticles: [Article], forPage page: Int) {
        if page == 1 {
            articlesSubject.send(newArticles)
        } else {
            let currentArticles = articlesSubject.value
            articlesSubject.send(currentArticles + newArticles)
        }
    }
    
    // MARK: - Layout Retrieval
    func getLayout(for articleId: String) -> ArticleLayoutCache? {
        let cacheKey = "\(articleId)_\(screenWidth)"
        return layoutCache[cacheKey]
    }
}
