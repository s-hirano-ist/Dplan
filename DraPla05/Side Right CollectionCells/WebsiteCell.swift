//
//  WebsiteCell.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/29.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import UIKit
import IGListKit
import SwipeCellKit
import SnapKit

class WebsiteCell: SwipeCollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.fontSize = 14
        label.numberOfLines = 0
        label.textColor = R.color.mainBlack()!
        //label.adjustsFontSizeToFitWidth = true
        //label.minimumScaleFactor = 0.8
        return label
    }()
    let URLLabel: UILabel = {
        let label = UILabel()
        label.fontSize = 8
        label.numberOfLines = 0
        label.textColor = R.color.mainBlack()!
        //label.adjustsFontSizeToFitWidth = true
        //label.minimumScaleFactor = 0.8
        return label
    }()
    let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
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
        contentView.addSubview(URLLabel)
        contentView.addSubview(imageView)
        contentView.layer.addSublayer(separator)
        setConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let offset:CGFloat = 16
    private func setConstraints(){
        titleLabel.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview().offset(offset)
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-4)
            make.bottom.equalTo(contentView.snp.centerY)
        })
        URLLabel.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview().offset(offset)
            make.top.equalTo(titleLabel.snp.bottom)
            make.right.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview().offset(-4)
        })
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: 0,
                                 height: 0)
        separator.frame = CGRect(x: offset,
                                 y: bounds.height - 0.5, width: bounds.width - offset, height: 0.5)
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.1
    }

    func setWebsite(title:String,url:String,image:UIImage?){
        titleLabel.text = title
        URLLabel.text = url
        if let image = image {
            imageView.image = image
        }else{
            imageView.image = .bookmark
        }
    }
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? R.color.mainLightGray()! : .clear
        }
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
