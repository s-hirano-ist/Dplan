//
//  ButtonOneView.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/27.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import UIKit
import SnapKit
import SnapKit

protocol ButtonOneViewDelegate {
    func onlyButtonClicked()->Void
}

class ButtonOneView: UIView {
    var delegate :ButtonOneViewDelegate?
    let centerButton = ButtonView()

    override init(frame: CGRect) {
        super.init(frame:frame)
        addSubview(centerButton)

        centerButton.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        })
        centerButton.setButton(title:"Done".localized)
        centerButton.delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension ButtonOneView:ButtonViewDelegate{
    func buttonTapped(view: ButtonView) {
        self.delegate?.onlyButtonClicked()
    }
}
