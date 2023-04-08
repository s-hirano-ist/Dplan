//
//  EmptyCell.swift
//  Dplan
//
//  Created by S.Hirano on 2020/04/05.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit

class EmptyCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = R.color.mainGray()!
        //titleLabel.adjustsFontSizeToFitWidth = true
        //titleLabel.minimumScaleFactor = 0.5
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(red: 200 / 255.0, green: 199 / 255.0, blue: 204 / 255.0, alpha: 1).cgColor
        return layer
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = R.color.mainWhite()!
        contentView.addSubview(titleLabel)
        contentView.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(100)
            make.right.left.width.equalToSuperview()
        })
        titleLabel.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(contentView).offset(4)
            make.bottom.equalTo(contentView.snp.centerY)
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
        })
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setText(text:String){
        titleLabel.text = text
    }
    override func layoutSubviews() {
        separator.frame = CGRect(x: 8, y: bounds.height - 0.5, width: bounds.width - 8, height: 0.5)
    }
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
