//
//  HeaderCell.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/29.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import Material
import SnapKit

class HeaderCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = R.color.mainGray()!
        titleLabel.minimumScaleFactor = 0.5
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = R.color.mainWhite()!
        contentView.addSubview(titleLabel)
        
        contentView.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(44)
            make.right.left.width.equalToSuperview()
        })
        titleLabel.snp.makeConstraints({ (make) -> Void in
            make.top.bottom.right.left.equalToSuperview().offset(10)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLabel(title:String,mapHidden:Bool){
        titleLabel.text = title
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
