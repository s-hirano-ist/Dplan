//
//  FlatNonImageCell.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/04/02.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import UIKit
import Material
import IGListKit
import SnapKit
import SwipeCellKit

protocol FlatNonImageCellDelegate {
    func nonImageFavoriteButtonPressed()->Void
    func nonImageShareButtonPressed()->Void
}
class FlatNonImageCell: SwipeCollectionViewCell {
    var flatCellDelegate: FlatNonImageCellDelegate?
    private let f = Settings().dateFormatter()

    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 1
        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.backgroundColor = .clear
        nameLabel.text = String.empty
        nameLabel.textColor = R.color.mainBlack()!
        nameLabel.textAlignment = .left
        nameLabel.adjustsFontSizeToFitWidth = true
        return nameLabel
    }()
    lazy var detailLabel: UILabel = {
        let detailLabel = UILabel()
        detailLabel.numberOfLines = 1
        //detailLabel.font = .systemFont(ofSize: 16)
        detailLabel.font = RobotoFont.regular(with: 12)
        //detailLabel.textColor = .mainGray
        detailLabel.textColor = R.color.mainBlack()!
        detailLabel.textAlignment = .left
        //detailLabel.numberOfLines = 0;
        //detailLabel.sizeToFit()
        return detailLabel
    }()

    lazy var favoriteButton:FABButton = {
        let favoriteButton = FABButton(image: UIImage(systemName: "star.fill"), tintColor: R.color.subRed()!)
        favoriteButton.pulseColor = R.color.mainWhite()!
        favoriteButton.backgroundColor = .clear
        favoriteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(favoriteButtonPressed(gestureRecognizer:))))
        return favoriteButton
    }()
    //MARK: IMPROVE isHidden Now
    lazy var shareButton: FABButton = {
        let shareButton = FABButton(image: Icon.cm.share, tintColor: R.color.mainGray()! )
        shareButton.pulseColor = R.color.mainWhite()!
        shareButton.backgroundColor = .clear
        shareButton.isHidden = true
        //shareButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareButtonPressed(gestureRecognizer:))))
        return shareButton
    }()

    @objc func shareButtonPressed(gestureRecognizer:UIGestureRecognizer) {
        shareButton.isHighlighted.toggle()
        flatCellDelegate?.nonImageShareButtonPressed()
    }
    @objc func favoriteButtonPressed(gestureRecognizer:UIGestureRecognizer) {
        favoriteButton.isHighlighted.toggle()
        flatCellDelegate?.nonImageFavoriteButtonPressed()
    }

    let separator: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(red: 200 / 255.0, green: 199 / 255.0, blue: 204 / 255.0, alpha: 1).cgColor
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = R.color.mainWhite()!

        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(shareButton)
        contentView.layer.addSublayer(separator)

        let fabMenuSize = CGSize(width: frame.height/3, height: frame.height/3)
        let offset = 16
        contentView.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(80)
            make.right.left.top.equalToSuperview()
        })
        favoriteButton.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(contentView).offset(offset)
            make.right.equalTo(contentView).offset(-offset)
            make.size.equalTo(fabMenuSize)
        })
        shareButton.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalTo(contentView).offset(-offset)
            make.right.equalTo(contentView).offset(-offset)
            make.size.equalTo(fabMenuSize)
        })
        nameLabel.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(contentView)
            make.height.equalTo(contentView.frame.height/2)
            make.left.equalToSuperview().offset(offset)
            make.right.equalTo(favoriteButton.snp.left).offset(-offset)
        })
        detailLabel.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(nameLabel.snp.bottom)
            make.bottom.equalTo(contentView)
            make.left.equalToSuperview().offset(offset)
            make.right.equalTo(favoriteButton.snp.left).offset(-offset)
        })
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension FlatNonImageCell {
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? R.color.mainLightGray()! : .clear
        }
    }
    
    func setData(withName name:String,detail:String,isFav:Bool){
        if name == String.empty {
            nameLabel.text = "Nothing entered".localized
        }else{
            nameLabel.text = name
        }
        if detail == String.empty{
            //detailLabel.text = "Nothing entered".localized
            detailLabel.text = detail
        }else{
            detailLabel.text = detail
        }
        favoriteButton.isHidden = !isFav
    }
}
