//
//  CustomNavigationBar.swift
//  BlogMobile
//
//  Created by yy on 2024/12/28.
//

import UIKit

class CustomNavigationBar: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .title
        label.textColor = .label
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    var onBackButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        
        addSubview(titleLabel)
        addSubview(backButton)
        addSubview(separatorLine)
        
        // Setup constraints using safe area
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).offset(16)
            make.centerY.equalTo(snp.bottom).offset(-22) // Center button at the bottom of the navigation bar
            make.size.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            // Ensure title is at least 16 points away from the buttons on both sides
            make.leading.equalTo(backButton.snp.trailing).offset(16)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-72)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        // Ensure the back button is interactive
        backButton.isUserInteractionEnabled = true
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    @objc private func backButtonTapped() {
        onBackButtonTapped?()
    }
}
