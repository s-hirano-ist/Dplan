//
//  MaterialButtons.swift
//  Dplan
//
//  Created by S.Hirano on 2019/12/09.
//  Copyright © 2019 Sola Studio. All rights reserved.
//

import UIKit
import Material
import SnapKit

enum State{
    case new
    case edit
    case show
    init() {
        self = .show
    }
}
enum URLState {
    case newURL //新規 URL
    case editURL //編集 URL

    case newURLCandidate
    case editURLCandidate
    init(){
        self = .newURL
    }
}

protocol ButtonThreeDelegate {
    func leftButtonClicked() -> Void
    func centerButtonClicked() -> Void
    func rightButtonClicked() -> Void
}

class ButtonThreeView: UIView {
    var delegate :ButtonThreeDelegate?

    let leftButton = ButtonView()
    let centerButton = ButtonView()
    let rightButton = ButtonView()

    override init(frame: CGRect) {
        super.init(frame:frame)
        addSubview(leftButton)
        addSubview(centerButton)
        addSubview(rightButton)

        leftButton.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.33)
        })
        centerButton.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(leftButton.snp.right)
            make.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.33)
        })

        rightButton.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(centerButton.snp.right)
            make.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.33)
        })

        leftButton.delegate = self
        centerButton.delegate = self
        rightButton.delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setButtons(state:PlanState){
        switch state {
        case .newDest:
            leftButton.setButton(title: "Cancel".localized)
            if RealmPlan().countLastDestination(at:NUMBER) == 2 {
                //MARK:1 plus the current one
                centerButton.disable()
            }else{
                centerButton.setButton(title:"Add new day".localized)
            }
            rightButton.setButton(title:"Add destination".localized)
        case .newDay:
            leftButton.setButton(title: "Cancel".localized)
            centerButton.disable()
            rightButton.setButton(title:"Add destination".localized)
        case .newPlan:
            leftButton.setButton(title: "Cancel".localized)
            centerButton.disable()
            rightButton.setButton(title:"Make new plan".localized)
        default:
            ERROR("ERROR IN STATE")
        }

    }
}
extension ButtonThreeView:ButtonViewDelegate{
    func buttonTapped(view: ButtonView) {
        switch view {
        case leftButton:
            self.delegate?.leftButtonClicked()
        case centerButton:
            self.delegate?.centerButtonClicked()
        case rightButton:
            self.delegate?.rightButtonClicked()
        default:
            ERROR("ERROR IN DELEGATE BUTTON")
        }
    }
}
