//
//  TitleView.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/17.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import DKImagePickerController
import SnapKit

protocol ImageViewDelegate {
    func addImage()->Void
    func activateImageView(page:Int,imageList:[UIImage])->Void
}

class ImageView: UIView {
    var delegate: ImageViewDelegate?

    private var numberOfPages = Int()
    private var currentPage = 0

    private var imageList:[UIImage?] = []
    lazy private var pageControl:UIPageControl = {
        let pageControl = UIPageControl()
        return pageControl
    }()
    lazy private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    lazy private var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add image".localized, for: .normal)
        button.addTarget(self,
                         action: #selector(addButtonPressed),
                         for: .touchUpInside)
        button.backgroundColor = R.color.mainLightGray()!
        button.setTitleColor(R.color.mainBlack()!, for: .normal)
        button.fontSize = 10
        button.cornerRadiusPreset = .cornerRadius3
        return button
    }()
    @objc private func addButtonPressed(_ sender: UIButton) {
        self.delegate?.addImage()
    }
    private func setIsEnabled(isEnabled:Bool){
        addButton.isHidden = !isEnabled
    }
    override init(frame: CGRect){
        super.init(frame: frame)
        setup()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    private func setup(){
        self.addSubview(scrollView)
        self.addSubview(pageControl)
        self.addSubview(addButton)
        scrollView.snp.makeConstraints({ (make) -> Void in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        })
        pageControl.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(20)
            make.width.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
        })
        addButton.snp.makeConstraints({ (make) -> Void in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(4)
            make.height.equalTo(30)
            make.width.equalTo(100)
        })
    }
}
extension ImageView {
    //MARK: ここが画像更新時に呼ばれる
    func setData(images:[UIImage?],isEnabled:Bool){
        imageList = []
        for image in images{
            imageList.append(image)
        }
        numberOfPages = imageList.count

        //MARK: constraints 更新
        self.snp.removeConstraints()
        self.snp.makeConstraints({(make) ->Void in
            if numberOfPages == 0 {
                if isEnabled {make.height.equalTo(100)
                }else{ make.height.equalTo(50) }
            }else{
                make.height.equalTo(275)
            }
        })
        self.layoutIfNeeded()
        setIsEnabled(isEnabled: isEnabled)
        reloadImagesView()
    }
    
    private func reloadImagesView(){
        for subview in scrollView.subviews{
            subview.removeFromSuperview()
        }
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        setupScrollView()
        for (index,image) in imageList.enumerated() {
            if let image = image{
                setImage(image: image,at: index)
            }
        }
    }
}

extension ImageView:UIScrollViewDelegate {
    private func setImage(image: UIImage,at page:Int) {
        let imageView = UIImageView(frame: scrollView.bounds)
        var frame = scrollView.bounds
        frame.origin.x = calculateX(at: page) //imageViewの初期X座標
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFill
        //imageView.clipsToBounds = true
        imageView.image = image
        imageView.tag = page
        scrollView.addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageClicked(gestureRecognizer:))))
    }
    @objc func imageClicked(gestureRecognizer: UITapGestureRecognizer) {
        guard let page = gestureRecognizer.view?.tag as Int? else { return }
        self.delegate?.activateImageView(page: page,imageList: imageList as! [UIImage])
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    private func setupScrollView() {
        // コンテンツ幅 = ページ数 x ページ幅
        scrollView.contentSize = CGSize(
            width: calculateX(at: numberOfPages),
            height: scrollView.frame.height
        )
    }
     private func calculateX(at position: Int) -> CGFloat {
         return scrollView.frame.width * CGFloat(position)
     }
     /// スクロールビューのオフセット位置からページインデックスを計算
     private func calculatePage(of scrollView: UIScrollView) -> Int {
         let width = scrollView.bounds.width
         let offsetX = scrollView.contentOffset.x
         let position = (offsetX - (width / 2)) / width
         return Int(floor(position) + 1)
     }
}
