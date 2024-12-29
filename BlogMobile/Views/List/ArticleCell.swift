//
//  ArticleCell.swift
//  BlogMobile
//
//  Created by yy on 2024/12/27.
//

import UIKit
import SnapKit
import Kingfisher

class ArticleCell: UICollectionViewCell {
    
    // MARK: - Properties
    private var titleHeightConstraint: Constraint?
    private var summaryHeightConstraint: Constraint?
    
    // MARK: - Constants
    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 12
    private let imageSize: CGFloat = 80
    private let tagSpacing: CGFloat = 4
    private let dateHeight: CGFloat = 15
    private let statsHeight: CGFloat = 15
    private let spacing: CGFloat = 8
    
    // MARK: - UI Components
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .body
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .title
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .body
        label.textColor = .subtitle
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var readCountLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .body
        return label
    }()
    
    private lazy var commentsLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .body
        return label
    }()
    
    // Image views for icons
    private lazy var readIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "views")?
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .body // Use the same color as text
        return imageView
    }()
    
    private lazy var commentsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "comments")?
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .body
        return imageView
    }()
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        return imageView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.backgroundColor = .white
        
        [separator, dateLabel, titleLabel, subtitleLabel,
         readCountLabel, commentsLabel, readIconImageView, commentsImageView, coverImageView].forEach {
            contentView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(horizontalPadding)
            make.top.equalToSuperview().offset(verticalPadding)
            make.height.equalTo(dateHeight)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(horizontalPadding)
            make.top.equalTo(dateLabel.snp.bottom).offset(verticalPadding)
            titleHeightConstraint = make.height.equalTo(0).constraint
        }
        
        coverImageView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(verticalPadding)
            make.right.equalToSuperview().inset(horizontalPadding)
            make.width.height.equalTo(imageSize)
            make.left.equalTo(titleLabel.snp.right).offset(horizontalPadding)
        }
    
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(horizontalPadding)
            make.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(spacing)
            summaryHeightConstraint = make.height.equalTo(0).constraint
        }
        
        readIconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(horizontalPadding)
            make.centerY.equalTo(readCountLabel)
            make.width.height.equalTo(10)
        }
        
        readCountLabel.snp.makeConstraints { make in
            make.left.equalTo(readIconImageView.snp.right).offset(2)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(spacing + verticalPadding)
            make.height.equalTo(statsHeight)
        }
    
        commentsImageView.snp.makeConstraints { make in
            make.left.equalTo(readCountLabel.snp.right).offset(horizontalPadding)
            make.centerY.equalTo(commentsLabel)
            make.width.height.equalTo(10)
        }
        
        commentsLabel.snp.makeConstraints { make in
            make.left.equalTo(commentsImageView.snp.right).offset(2)
            make.centerY.equalTo(readCountLabel)
            make.height.equalTo(statsHeight)
        }
    }
    
    private func calculateTagWidth(for text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 12)
        let textWidth = text.boundingRectFast(
            withMaxWidth: CGFloat.greatestFiniteMagnitude,
            font: font
        ).width
        return textWidth + 16 // Add left and right padding
    }
    
    // MARK: - Configuration
    func configure(with article: Article, layout: ArticleLayoutCache) {
        dateLabel.text = article.publishTime.toFormattedDate()
        titleLabel.text = article.title
        subtitleLabel.text = article.excerpt
        readCountLabel.text = "\(article.commentCount)"
        commentsLabel.text = "\(article.views ?? 0)"
        setCover(urlString: article.cover, size: coverImageView.bounds.size)
        
        // Update height constraints
        titleHeightConstraint?.update(offset: layout.titleHeight)
        summaryHeightConstraint?.update(offset: layout.summaryHeight)
        
        // Trigger layout update
        setNeedsLayout()
    }
    
    private func setCover(urlString: String?, size: CGSize) {
        guard var urlString = urlString else {
            return
        }
        let urlPrefix = "https://www.arcblock.io/blog/uploads"
        
        // Handle base URL
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = urlPrefix + urlString
        }
        
        coverImageView.setUrl(urlString, size: size, mode: .local)
    }
}
