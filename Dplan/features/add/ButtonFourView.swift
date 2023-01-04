//
//  ButtonFourView.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/17.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import SnapKit

protocol ButtonFourViewDelegate {
    func oneButtonClicked()->Void
    func twoButtonClicked()->Void
    func threeButtonClicked()->Void
    func fourButtonClicked()->Void
}
class ButtonFourView: UIView {
    var delegate :ButtonFourViewDelegate?

    let oneButton = ButtonView()
    let twoButton = ButtonView()
    let threeButton = ButtonView()
    let fourButton = ButtonView()

    override init(frame: CGRect) {
        super.init(frame:frame)
        addSubview(oneButton)
        addSubview(twoButton)
        addSubview(threeButton)
        addSubview(fourButton)

        oneButton.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.25)
        })
        twoButton.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(oneButton.snp.right)
            make.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.25)
        })

        threeButton.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(twoButton.snp.right)
            make.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.25)
        })
        fourButton.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(threeButton.snp.right)
            make.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.25)
        })

        oneButton.setButton(title: "Close".localized)
        twoButton.setButton(title:"Open in map app".localized)
        //threeButton.setButton(title:"Add here to other data".localized)
        threeButton.isHidden = true
        //MARK: 現状無効化 ボタン

        fourButton.setButton(title:"Edit destination".localized)
        oneButton.delegate = self
        twoButton.delegate = self
        threeButton.delegate = self
        fourButton.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ButtonFourView:ButtonViewDelegate{
    func buttonTapped(view: ButtonView) {
        switch view {
        case oneButton:
            self.delegate?.oneButtonClicked()
        case twoButton:
            self.delegate?.twoButtonClicked()
        case threeButton:
            self.delegate?.threeButtonClicked()
        case fourButton:
            self.delegate?.fourButtonClicked()
        default:
            ERROR("ERROR IN DELEGATE BUTTON")
        }
    }
}
