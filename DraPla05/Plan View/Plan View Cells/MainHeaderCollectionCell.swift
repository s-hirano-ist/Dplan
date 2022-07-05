//
//  MainHeaderCollectionCell.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/04/01.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import UIKit
import SnapKit
import SwipeCellKit

class NonEditHeaderCollectionCell: UICollectionViewCell {
    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.fontSize = 12
        label.text = "出発時刻"
        return label
    }()
    lazy var centerLabel: UILabel = {
        let label = UILabel()
        label.fontSize = 12
        label.text = "目的地"
        return label
    }()
    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.fontSize = 12
        label.text = "滞在時間"
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
            make.width.equalTo(49.5)
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
}
