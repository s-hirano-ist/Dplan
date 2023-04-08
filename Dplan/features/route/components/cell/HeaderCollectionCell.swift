//
//  HeaderCollectionCell.swift
//  Dplan
//
//  Created by S.Hirano on 2020/04/01.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import SnapKit
import SwipeCellKit

class HeaderCollectionCell: UICollectionViewCell {
    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.fontSize = 12
        label.adjustsFontSizeToFitWidth = true
        label.text = "Time".localized
        return label
    }()
    lazy var centerLabel: UILabel = {
        let label = UILabel()
        label.fontSize = 12
        label.adjustsFontSizeToFitWidth = true
        label.text = "Name of place".localized
        return label
    }()
    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.fontSize = 12
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.text = "Time at destination".localized
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        contentView.addSubview(leftLabel)
        contentView.addSubview(centerLabel)
        contentView.addSubview(rightLabel)

        leftLabel.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(contentView).offset(16)
            make.width.equalTo(49.5)
            make.top.equalTo(4)
            make.bottom.equalTo(4)
        })
        rightLabel.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(contentView).offset(-16)
            make.width.equalTo(100)
            make.top.equalTo(4)
            make.bottom.equalTo(4)
        })
        centerLabel.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(leftLabel.snp.right).offset(8)
            make.right.equalTo(rightLabel.snp.left)
            make.top.equalTo(4)
            make.bottom.equalTo(4)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? R.color.mainLightGray()! : .clear
        }
    }
}
