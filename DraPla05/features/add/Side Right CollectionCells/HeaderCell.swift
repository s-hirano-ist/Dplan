//
//  HeaderCell.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/29.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import UIKit
import IGListKit
import Material
import SnapKit

protocol HeaderCellDelegate {
    func showAllButtonClicked()->Void
    func showMapButtonClicked()->Void
}

class HeaderCell: UICollectionViewCell {
    var delegate: HeaderCellDelegate?
    var isShowAll = true

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = R.color.mainGray()!
        titleLabel.minimumScaleFactor = 0.5
        return titleLabel
    }()
    lazy var showMapButton:FlatButton = {
        let button = FlatButton(title: "Show map".localized)
        button.pulseColor = .lightGray
        button.backgroundColor = .clear
        button.fontSize = 12
        //button.titleColor = R.color.mainBlack()!
        button.titleColor = R.color.mainGray()!
        button.isHidden = true
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMapButtonPressed(gestureRecognizer:))))
        return button
    }()

    lazy var showAllButton:FlatButton = {
        let button = FlatButton(title: "Show less".localized)
        button.pulseColor = .lightGray
        button.backgroundColor = .clear
        button.fontSize = 12
        button.titleColor = R.color.mainBlack()!
        button.isHidden = true
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAllButtonPressed(gestureRecognizer:))))
        return button
    }()
    let offset:CGFloat = 16
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = R.color.mainWhite()!
        setAll()
        contentView.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(44)
            make.right.left.width.equalToSuperview()
        })

        showAllButton.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(contentView).offset(-offset)
            make.width.equalTo(0)
            make.top.equalTo(contentView).offset(4)
            make.bottom.equalTo(contentView).offset(-4)
        })
        showMapButton.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(showAllButton.snp.left).offset(-4)
            make.width.equalTo(frame.width/6)
            make.top.equalTo(contentView).offset(4)
            make.bottom.equalTo(contentView).offset(-4)
        })
        titleLabel.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(contentView).offset(4)
            make.bottom.equalTo(contentView).offset(-4)
            make.left.equalTo(contentView).offset(offset)
            make.right.equalTo(showMapButton.snp.left)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLabel(title:String,mapHidden:Bool){
        titleLabel.text = title
        //showMapButton.isHidden = mapHidden
    }

    private func setAll(){
        contentView.addSubview(showAllButton)
        contentView.addSubview(showMapButton)
        contentView.addSubview(titleLabel)
    }
    @objc func showAllButtonPressed(gestureRecognizer:UIGestureRecognizer) {
        if isShowAll {
            showAllButton.setTitle("Show all".localized, for: .normal)
        }else{
            showAllButton.setTitle("Show less".localized, for: .normal)
        }
        isShowAll.toggle()
        //self.delegate?.showAllButtonClicked()
    }

    @objc func showMapButtonPressed(gestureRecognizer:UIGestureRecognizer) {
        //self.delegate?.showMapButtonClicked()
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
