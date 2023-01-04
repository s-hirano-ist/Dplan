//
//  EventCollectionCell.swift
//  Dplan
//
//  Created by S.Hirano on 2020/04/01.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import SwipeCellKit
import SnapKit
import IGListKit

class EventCollectionCell: SwipeCollectionViewCell {
    var timeAt: UILabel = {
        let label = UILabel()
        label.fontSize = 17
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    var titleLabel: UILabel = {
        let label = UILabel()
        label.fontSize = 17
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    var detailLabel: UILabel = {
        let label = UILabel()
        label.fontSize = 12
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    var timeIn: UILabel = {
        let label = UILabel()
        label.fontSize = 17
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = .clear
        
        contentView.addSubview(timeAt)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(timeIn)
        setConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setConstraints(){
        timeAt.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(contentView).offset(16)
            make.width.equalTo(49.5)
            make.top.equalTo(contentView).offset(5)
            make.height.equalTo(21)
        })
        timeIn.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(contentView).offset(-16)
            make.width.equalTo(49.5)
            make.top.equalTo(contentView).offset(5)
            make.height.equalTo(21)
        })
        titleLabel.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(timeAt.snp.right).offset(8)
            make.right.equalTo(timeIn.snp.left).offset(-8)
            make.top.equalTo(contentView).offset(5)
            make.height.equalTo(21)
        })
        detailLabel.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(timeAt.snp.right).offset(8)
            make.right.equalTo(timeIn.snp.left).offset(-8)
            make.height.equalTo(15)
            make.bottom.equalTo(contentView).offset(-6)
        })
    }
}

extension EventCollectionCell {
    func setHeaderCell(with data:EachData,isEditing:Bool){
        timeAt.text = data.convertedTime
        timeIn.text = Settings().dateFormatter().string(from: data.time)

        if data.name == String.empty {
            titleLabel.text = "Not entered".localized
        }else{
            titleLabel.text = data.name
        }
        if data.detail == String.empty {
            //detailLabel.text = "Not entered".localized
            detailLabel.text = data.detail
        }else{
            detailLabel.text = data.detail
        }
        detailLabel.textColor = R.color.mainGray()!

        if isEditing {
            timeAt.textColor = .clear
            timeIn.textColor = .clear
        } else {
            timeAt.textColor = R.color.mainCyan()!
            timeIn.textColor = R.color.mainCyan()!
        }
        if data.latitude == 0 {
            //ERROR IN LOCATION
            titleLabel.textColor = R.color.subRed()!
        }else{
            titleLabel.textColor = R.color.mainBlack()!
        }
    }
    func setCell(with data:EachData,isEditing : Bool) {
        timeAt.text = data.convertedTime
        timeIn.text = data.convertedTimeIn

        if data.name == String.empty {
            titleLabel.text = "Not entered".localized
        }else{
            titleLabel.text = data.name
        }
        if data.detail == String.empty {
            //detailLabel.text = "Not entered".localized
            detailLabel.text = String.empty
        }else{
            detailLabel.text = data.detail
        }
        detailLabel.textColor = R.color.mainGray()!

        if isEditing {
            timeAt.textColor = .clear
            timeIn.textColor = .clear
        } else {
            timeAt.textColor = R.color.mainCyan()!
            timeIn.textColor = R.color.mainCyan()!
        }
        //MARK: ERROR IN LOCATION
        if data.latitude == 0 {
            titleLabel.textColor = R.color.subRed()!
        }else{
            titleLabel.textColor = R.color.mainBlack()!
        }
    }

    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? R.color.mainLightGray()! : .clear
        }
    }
}

