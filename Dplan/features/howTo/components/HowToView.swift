//
//  HowToView.swift
//  Dplan
//
//  Created by S.Hirano on 2020/04/16.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

/*
 * 初回起動画面
 * 機能紹介（最後以外のページ）前に戻る，後ろに進むボタンを配置
 */

import UIKit
import SnapKit
import Material

protocol HowToViewDelegate {
    func leftButtonClicked()->Void
    func rightButtonClicked()->Void
}

class HowToView: UIView {
    var delegate:HowToViewDelegate?
    
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
    lazy var rightButton:FABButton = {
        let button = FABButton()
        button.image = UIImage(systemName: "arrow.right")
        button.tintColor = R.color.mainWhite()!
        button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(nextButton(gestureRecognizer:))))
        return button
    }()
    
    
    @objc func backButton(gestureRecognizer:UIGestureRecognizer){
        self.delegate?.leftButtonClicked()
    }
    @objc func nextButton(gestureRecognizer:UIGestureRecognizer){
        self.delegate?.rightButtonClicked()
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
        self.addSubview(rightButton)
        
        let offset:CGFloat = 32
        
        imageView.snp.makeConstraints({ (make) -> Void in
            make.left.right.top.bottom.equalToSuperview()
        })
        
        leftButton.snp.makeConstraints({ (make) -> Void in
            make.height.width.equalTo(44)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.left.equalToSuperview().offset(offset/2)
        })
        
        rightButton.snp.makeConstraints({ (make) -> Void in
            make.height.width.equalTo(44)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.right.equalToSuperview().offset(-offset/2)
        })
    }
    
    
    func setImage(image:UIImage){
        imageView.image = image
    }
}
