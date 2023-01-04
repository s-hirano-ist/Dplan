//
//  FirstScrollView.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/04/16.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

/*
 * 初回起動画面
 * 機能紹介の画面
 */

import UIKit
import SnapKit

class FirstBootView: UIViewController {
    let numberOfPages = 5 //MARK: for how many pages
    let howToImages = [R.image.promotion07()!,
                       R.image.promotion02()!,
                       R.image.promotion06()!,
                       R.image.promotion08()!]
    var currentPage = 0
    
    lazy private var pageControl:UIPageControl = {
        let pageControl = UIPageControl()
        return pageControl
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = R.color.mainWhite()!
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
}

extension FirstBootView {

    override func viewDidLoad() {
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        setData()
        scrollView.isScrollEnabled = false // 最初の画面は同意が必須のためスクロール不可
    }

    private func setup(){

        view.addSubview(scrollView)
        view.addSubview(pageControl)

        scrollView.snp.makeConstraints({ (make) -> Void in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        })
        
        pageControl.snp.makeConstraints({ (make) -> Void in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        })
    }
    
    private func setData(){
        pageControl.numberOfPages = numberOfPages - 1 //最初のページはページコントロール対象外
        pageControl.currentPage = 0

        scrollView.delegate = self
        // コンテンツ幅 = ページ数 x ページ幅
        scrollView.contentSize = CGSize(
            width: calculateX(at: numberOfPages),
            height: scrollView.frame.height
        )
        
        setAgreementView()
        setImageView(at: 1)
        setImageView(at: 2)
        setImageView(at: 3)
        setLastImageView(at: 4)
    }
}

extension FirstBootView: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = currentPage - 1 //最初の画面はページコントロール対象外
    }

     private func calculateX(at position: Int) -> CGFloat {
         return scrollView.frame.width * CGFloat(position)
     }
     private func calculatePage(of scrollView: UIScrollView) -> Int {
         // スクロールビューのオフセット位置からページインデックスを計算
         let width = scrollView.bounds.width
         let offsetX = scrollView.contentOffset.x
         let position = (offsetX - (width / 2)) / width
         return Int(floor(position) + 1)
     }
}

extension FirstBootView: HowToViewDelegate, HowToLastViewDelegate, AgreementViewDelegate {
    func leftButtonClicked() {
        moveToPrevious()
    }
    func rightButtonClicked() {
        moveToNext()
    }
    func centerButtonClicked() {
        UserDefaults.standard.set(false, forKey: "isFirstTime")
        self.dismiss(animated: true, completion: nil)
    }
    func agreeButtonPressed() {
        scrollView.isScrollEnabled = true
        moveToNext()
    }
    private func moveToPrevious(){
        currentPage -= 1
        let x = calculateX(at: currentPage)
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        if currentPage == 0{
            scrollView.isScrollEnabled = false
        }
    }
    private func moveToNext(){
        currentPage += 1
        let x = calculateX(at: currentPage)
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
}

// MARK: 説明画像の配置
extension FirstBootView {
    private func setAgreementView(){
        var frame = scrollView.bounds
        frame.origin.x = calculateX(at: 0) //MARK: 初期は0ページ目

        let agreementView = AgreementView(frame: frame)
        agreementView.delegate = self
        scrollView.addSubview(agreementView)
    }
    
    private func setImageView(at page:Int) {
        var frame = scrollView.bounds
        frame.origin.x = calculateX(at: page) //imageViewの初期X座標
        let howToView = HowToView(frame: frame)
        howToView.setImage(image: howToImages[page-1])
        howToView.delegate = self
        scrollView.addSubview(howToView)
    }
    
    private func setLastImageView(at page:Int) {
        var frame = scrollView.bounds
        frame.origin.x = calculateX(at: page) //imageViewの初期X座標
        let howToLastView = HowToLastView(frame:frame)
        howToLastView.delegate = self
        howToLastView.setImage(image: howToImages[page-1])
        scrollView.addSubview(howToLastView)
    }
}
