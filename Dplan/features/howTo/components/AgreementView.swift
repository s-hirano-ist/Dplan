//
//  AgreementView.swift
//  Dplan
//
//  Created by S.Hirano on 2020/04/16.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

/*
 * 初回起動画面
 * 利用規約，プライバシーポリシーの同意画面
 */

import UIKit
import SnapKit
import Material

protocol AgreementViewDelegate {
    func agreeButtonPressed()->Void
}

class AgreementView: UIView {
    
    var delegate:AgreementViewDelegate?
    
    lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Dplan".localized
        label.backgroundColor = .clear
        label.textColor = R.color.mainBlack()!
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 38, weight:.regular)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    lazy var iconImage:UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.appIconBackground()!
        return imageView
    }()
    lazy var termsOfServiceView:UILabel = {
        let label = UILabel()
        label.text = "このアプリケーションを利用すると下記リンクのDplanの利用規約とプライバシーポリシーに同意したことになります。".localized
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = R.color.mainBlack()!
        label.font = UIFont.systemFont(ofSize: 14, weight:.regular)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    lazy var termsOfServiceButton:RaisedButton = {
        let button = Settings().raisedButton()
        button.setTitle("Terms of service".localized, for: .normal)
        button.setTitleColor(R.color.mainBlack()!, for: .normal)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(termsOfServiceButtonClicked(gestureRecognizer:))))
        return button
    }()
    lazy var privacyButton:RaisedButton = {
        let button = Settings().raisedButton()
        button.setTitle("Privacy policy".localized, for: .normal)
        button.setTitleColor(R.color.mainBlack()!, for: .normal)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(privacyButtonClicked(gestureRecognizer:))))
        return button
    }()
    lazy var agreeButton:RaisedButton = {
        let button = Settings().raisedButton()
        button.setTitle("利用規約とプライバシーポリシーに同意".localized, for: .normal)
        button.setTitleColor(R.color.mainWhite()!, for: .normal)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(agreeButtonClicked(gestureRecognizer:))))
        button.backgroundColor = R.color.subNavy()!
        return button
    }()

    @objc func termsOfServiceButtonClicked(gestureRecognizer:UIGestureRecognizer){
        let url = URL(string: "https://www.google.com/")
        if let url = url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    @objc func privacyButtonClicked(gestureRecognizer:UIGestureRecognizer){
        let url = URL(string: "https://www.google.com/")
        if let url = url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    @objc func agreeButtonClicked(gestureRecognizer:UIGestureRecognizer){
        self.delegate?.agreeButtonPressed()
    }

    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = R.color.mainWhite()!
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AgreementView {

    private func setupConstraints(){
        self.addSubview(welcomeLabel)
        self.addSubview(iconImage)
        self.addSubview(termsOfServiceButton)
        self.addSubview(privacyButton)
        self.addSubview(termsOfServiceView)
        self.addSubview(agreeButton)

        let offset:CGFloat = 32

        welcomeLabel.snp.makeConstraints({ (make) -> Void in
            make.right.equalToSuperview().offset(-offset)
            make.left.equalToSuperview().offset(offset)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(100)
        })
        iconImage.snp.makeConstraints({ (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.snp.centerY).offset(-100)
            make.height.width.equalTo(128)
        })

        termsOfServiceView.snp.makeConstraints({ (make) -> Void in
            make.right.equalToSuperview().offset(-offset)
            make.left.equalToSuperview().offset(offset)
            make.top.equalTo(iconImage.snp.bottom).offset(offset)
            make.height.equalTo(100)
        })

        termsOfServiceButton.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview().offset(offset)
            make.right.equalToSuperview().offset(-offset)
            make.top.equalTo(termsOfServiceView.snp.bottom).offset(offset)
            make.height.equalTo(44)
        })

        privacyButton.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview().offset(offset)
            make.right.equalToSuperview().offset(-offset)
            make.top.equalTo(termsOfServiceButton.snp.bottom).offset(offset/4)
            make.height.equalTo(44)
        })

        agreeButton.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(44)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        })
    }
}
