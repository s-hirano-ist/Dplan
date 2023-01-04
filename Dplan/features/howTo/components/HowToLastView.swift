//
//  HowToLastView.swift
//  Dplan
//
//  Created by S.Hirano on 2020/04/16.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

/*
 * 初回起動画面
 * 機能紹介（最後のページ）利用開始ボタンを配置
 */

import UIKit
import SnapKit
import Material

protocol HowToLastViewDelegate {
    func leftButtonClicked()->Void
    func centerButtonClicked()->Void
}

class HowToLastView: UIView {
    var delegate:HowToLastViewDelegate?

    lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    lazy var leftButton:FABButton = {
        let button = FABButton()
        button.image = UIImage(systemName: "arrow.left")
        button.tintColor = R.color.mainWhite()!
        button.isUserInteractionEnabled = true
        button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(backButton(gestureRecognizer:))))
        return button
    }()
    lazy var centerButton:RaisedButton = {
        let button = RaisedButton()
        button.setTitle("利用開始".localized, for: .normal)
        button.tintColor = R.color.mainWhite()!
        button.backgroundColor = R.color.subNavy()!
        button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(centerButtonClicked(gestureRecognizer:))))
        return button
    }()

    @objc func backButton(gestureRecognizer:UIGestureRecognizer){
        self.delegate?.leftButtonClicked()
    }
    @objc func centerButtonClicked(gestureRecognizer:UIGestureRecognizer){
        self.delegate?.centerButtonClicked()
    }

    override init(frame: CGRect) {
        super.init(frame:frame)
        setConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints(){
        self.addSubview(imageView)
        self.addSubview(leftButton)
        self.addSubview(centerButton)

        let offset:CGFloat = 32

        imageView.snp.makeConstraints({ (make) -> Void in
            make.left.right.top.bottom.equalToSuperview()
        })
        
        leftButton.snp.makeConstraints({ (make) -> Void in
            make.height.width.equalTo(44)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.left.equalToSuperview().offset(offset/2)
        })
        centerButton.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(44)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        })
    }

    func setImage(image:UIImage){
        imageView.image = image
    }
}
