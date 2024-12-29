//
//  ArticleSectionController.swift
//  BlogMobile
//
//  Created by yy on 2024/12/27.
//

import IGListKit

class ArticleSectionController: ListSectionController {
    private var article: Article?
    private weak var bloc: ArticleListBloc?
    
    init(bloc: ArticleListBloc) {
        self.bloc = bloc
        super.init()
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let article = article else { return .zero }
        let width = collectionContext?.containerSize.width ?? 0
        let layout = ArticleLayoutCacheManager.shared.getLayout(for: article, width: width)
        return CGSize(width: width, height: layout.totalHeight)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let context = collectionContext,
              let article = article,
              let layout = bloc?.getLayout(for: article.id),
              let cell: ArticleCell = context.dequeueReusableCell(of: ArticleCell.self, for: self, at: index) as? ArticleCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: article, layout: layout)
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        guard let article = article else { return }

        guard let cell = collectionContext?.cellForItem(at: index, sectionController: self) else { return }
        
        // 获取cell在window中的frame
        let cellFrame = cell.convert(cell.bounds, to: nil)
        
        let detailVC = ArticleDetailViewController(article: article)
        detailVC.modalPresentationStyle = .custom
        
        let transitionDelegate = CustomTransitionDelegate(fromCardFrame: cellFrame)
        detailVC.transitioningDelegate = transitionDelegate
        detailVC.cardTransitionDelegate? = transitionDelegate
        
        viewController?.present(detailVC, animated: true)
    }
    
    override func didUpdate(to object: Any) {
        article = object as? Article
    }
}
