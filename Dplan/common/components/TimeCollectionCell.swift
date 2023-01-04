//
//  TimeCollectionCell.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/04/01.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit
import SwipeCellKit
class TimeCollectionCell: SwipeCollectionViewCell {

    private var transportImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .left
        return imageView
    }()
    private var timeTo:UILabel = {
        let label = UILabel()
        label.fontSize = 17
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private var isLocked: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .left
        return imageView
    }()
    private var line: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.mainBlack()!
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = .clear

        contentView.addSubview(transportImage)
        contentView.addSubview(timeTo)
        contentView.addSubview(isLocked)
        contentView.addSubview(line)
        setConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setConstraints(){
        transportImage.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(contentView).offset(16)
            make.width.equalTo(40)
            make.top.equalTo(contentView).offset(4)
            make.bottom.equalTo(contentView).offset(-4)
        })
        timeTo.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(contentView).offset(74)
            //make.width.equalTo(frame.width/2)
            make.top.equalTo(contentView).offset(4)
            make.bottom.equalTo(contentView).offset(-4)
        })
        isLocked.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(timeTo.snp.right).offset(4)
            make.width.equalTo(frame.height/2)
            make.top.equalTo(contentView).offset(4)
            make.bottom.equalTo(contentView).offset(-4)
        })
        line.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(isLocked.snp.right)
            make.right.equalTo(contentView)
            make.height.equalTo(0.5)
            make.centerY.equalTo(contentView)
        })
    }

    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? R.color.mainLightGray()! : .clear
        }
    }
}

//MARK: for access from collecionView
extension TimeCollectionCell {
    func setCell(with data:EachData) {
        if data.isLocked{
            isLocked.tintColor = R.color.mainBlack()!
        }else {
            isLocked.tintColor = .clear
        }
        switch data.transport{
        case 0: transportImage.image = .carImage
        case 1: transportImage.image = .trainImage
        case 2: transportImage.image = .walkImage
        default: transportImage.image = .bookmark//ERROR
        }
        transportImage.tintColor = R.color.mainBlack()!
        isLocked.image = .lockFill

        let min: Int = Int(data.timeTo)/60 % 60
        let hour: Int = (Int(data.timeTo)/60-min)/60
        if  hour == 23 && min == 50{
            timeTo.text = "0 min".localized
        }else if (min == 0 && hour == 0) {
            timeTo.text = "N/A".localized
            timeTo.textColor = R.color.subRed()!
            return
        }else if hour == 0{
            timeTo.text = String(min) + "min".localized
        }else{
            timeTo.text = String(hour) + "hr".localized + " " + String(min) + "min".localized
        }
        //MARK: LOCKED ならば グレー表示．
        if data.isLocked == false {
            timeTo.textColor = R.color.mainCyan()!
        }else {
            timeTo.textColor = R.color.mainGray()!
        }
    }
}

