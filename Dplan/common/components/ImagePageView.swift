//
//  ImagePageView.swift
//  Dplan
//
//  Created by S.Hirano on 2019/12/12.
//  Copyright © 2019 Sola Studio. All rights reserved.
//

import UIKit
import CropViewController
import RxSwift
import RxCocoa


protocol ImagePageViewDelegate {
    func deleteImage(at index:Int)->Void
    func editImage(of image:UIImage,index: Int)->Void
}

class ImagePageView: UIViewController {
    lazy var mainScrollView: UIScrollView = {
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
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak private var editButton: UIButton!
    @IBOutlet weak private var shareButton: UIButton!
    @IBOutlet weak private var pageControl: UIPageControl!
    @IBOutlet weak private var deleteButton: UIButton!
    
    var currentPage = Int()
    var images:[UIImage]!
    var canDelete:Bool = false
    var canCrop = false

    var delegate:ImagePageViewDelegate?

    private var numberOfPages = 0
    private let disposeBag = DisposeBag()

    @IBAction private func shareButtonPressed(_ sender: Any) {
        Segues().imageTypeShare(image: images[calculatePage(of: mainScrollView)], controller: self)
    }
    @IBAction func editButtonPressed(_ sender: Any) {
        currentPage = calculatePage(of: mainScrollView)
        let subScrollView = mainScrollView.subviews[currentPage] as! UIScrollView
        let imageView = subScrollView.subviews[0] as! UIImageView

        let cropController = CropViewController(croppingStyle: .default, image: imageView.image!)

        cropController.delegate = self
        cropController.aspectRatioPreset = .presetOriginal

        cropController.toolbar.resetButton.setTitle("Reset".localized, for: .normal)
        cropController.toolbar.resetButton.setTitleColor(R.color.mainWhite()!, for: .normal)
        cropController.toolbar.resetButton.setImage(nil, for: .normal)

        cropController.toolbar.rotateButton.setImage(UIImage(systemName: "rotate.left.fill"), for: .normal)
        cropController.toolbar.rotateClockwiseButton!.setImage(UIImage(systemName: "rotate.right.fill"), for: .normal)
        cropController.toolbar.clampButton.setImage(UIImage(systemName: "aspectratio.fill"), for: .normal)
        self.present(cropController, animated: true, completion: nil)
    }
    @IBAction private func closeButtonPressed(_ sender: Any) {
        Settings().reloadRightViewDismiss(controller: self)
    }
    @IBAction private func deleteButtonPressed(_ sender: Any) {
        let page = calculatePage(of: mainScrollView)
        self.delegate?.deleteImage(at: page)
        images.remove(at: page)
        numberOfPages = images.count
        if numberOfPages <= 0 {
            self.dismiss(animated: true, completion: nil)
        }
        pageControl.numberOfPages = numberOfPages
        currentPage = 0
        for view in mainScrollView.subviews{
            view.removeFromSuperview()
        }
        calculateMainScrollViewContextSize()
        (0..<numberOfPages).forEach { page in
            let subScrollView = generateSubScrollView(at: page)
            mainScrollView.addSubview(subScrollView)
            subScrollView.addSubview(generateImageView(at: page))
        }
        let x = calculateX(at: currentPage)
        mainScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let edge = UIEdgeInsets(top: 100, left: 0, bottom: 100, right: 0)
        mainScrollView.frame = CGRect(x: edge.left,
                                      y: edge.top,
                                      width: view.frame.width - edge.left - edge.right,
                                      height: view.frame.height - edge.top - edge.bottom)
        view.addSubview(mainScrollView)

        numberOfPages = images.count
        pageControl.numberOfPages = images.count
        pageControl.currentPage = currentPage
        setupClosePanGesture()
        view.backgroundColor = R.color.mainBlack()!
        deleteButton.isHidden = !canDelete
        editButton.isHidden = !canCrop
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculateMainScrollViewContextSize()
        (0..<numberOfPages).forEach { page in
            let subScrollView = generateSubScrollView(at: page)
            mainScrollView.addSubview(subScrollView)
            subScrollView.addSubview(generateImageView(at: page))
        }
        let x = calculateX(at: currentPage)
        mainScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
    }

    //MARK: for image
    private func generateImageView(at page: Int) -> UIImageView {
        let frame = mainScrollView.bounds
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = image(at: page)
        return imageView
    }
    private func image(at page: Int) -> UIImage? {
        return images[page]
    }
}
//MARK: for scroll view
extension ImagePageView: UIScrollViewDelegate {
    //MARK: for page Control
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(mainScrollView.contentOffset.x / mainScrollView.frame.size.width)
    }

    private func calculateMainScrollViewContextSize() {
        // コンテンツ幅 = ページ数 x ページ幅
        mainScrollView.contentSize = CGSize(
            width: calculateX(at: numberOfPages),
            height: mainScrollView.frame.height
        )
    }
    //MARK: for zooming
    private func generateSubScrollView(at page: Int) -> UIScrollView {
        let frame = calculateSubScrollViewFrame(at: page)
        let subScrollView = UIScrollView(frame: frame)
        subScrollView.delegate = self
        subScrollView.maximumZoomScale = 3.0
        subScrollView.minimumZoomScale = 1.0
        //MARK: probably default → isScrollEnabled = true
        //MARK: never add → isPagingEnabled = true
        subScrollView.showsHorizontalScrollIndicator = false
        subScrollView.showsVerticalScrollIndicator = false
        //double tap gesture
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapSubScrollView(_:)))
        gesture.numberOfTapsRequired = 2
        subScrollView.addGestureRecognizer(gesture)
        return subScrollView
    }
    private func calculateSubScrollViewFrame(at page: Int) -> CGRect {
        var frame = mainScrollView.bounds
        frame.origin.x = calculateX(at: page)
        return frame
    }
    private func calculateX(at position: Int) -> CGFloat {
        return mainScrollView.frame.width * CGFloat(position)
    }

    /// サブスクロールビューがダブルタップされた時
    @objc private func didDoubleTapSubScrollView(_ gesture: UITapGestureRecognizer) {
        guard let subScrollView = gesture.view as? UIScrollView else { return }
        if subScrollView.zoomScale < subScrollView.maximumZoomScale {
            // タップされた場所を中心に拡大する
            let location = gesture.location(in: subScrollView)
            let rect = calculateRectForZoom(location: location, scale: subScrollView.maximumZoomScale)
            subScrollView.zoom(to: rect, animated: true)
        } else {
            subScrollView.setZoomScale(subScrollView.minimumZoomScale, animated: true)
        }
    }
    /// スクロールビューのオフセット位置からページインデックスを計算
    private func calculatePage(of scrollView: UIScrollView) -> Int {
        let width = scrollView.bounds.width
        let offsetX = scrollView.contentOffset.x
        let position = (offsetX - (width / 2)) / width
        return Int(floor(position) + 1)
    }

    /// タップされた位置と拡大率から拡大後のCGRectを計算する
    private func calculateRectForZoom(location: CGPoint, scale: CGFloat) -> CGRect {
        let size = CGSize(
            width: mainScrollView.bounds.width / scale,
            height: mainScrollView.bounds.height / scale
        )
        let origin = CGPoint(
            x: location.x - size.width / 2,
            y: location.y - size.height / 2
        )
        return CGRect(origin: origin, size: size)
    }

    private func resetZoomScaleOfSubScrollViews(without exclusionSubScrollView: UIScrollView) {
        for subview in mainScrollView.subviews {
            guard
                let subScrollView = subview as? UIScrollView,
                subScrollView != exclusionSubScrollView
                else {
                    continue
            }
            subScrollView.setZoomScale(subScrollView.minimumZoomScale, animated: false)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != mainScrollView { return }

        let page = calculatePage(of: scrollView)
        if page == currentPage { return }
        currentPage = page

        //pageControl.currentPage = page
        // 他のすべてのサブスクロールビューの拡大率をリセット
        resetZoomScaleOfSubScrollViews(without: scrollView)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first as? UIImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let imageView = scrollView.subviews.first as? UIImageView else { return }

        scrollView.contentInset = UIEdgeInsets(
            top: max((scrollView.frame.height - imageView.frame.height) / 2, 0),
            left: max((scrollView.frame.width - imageView.frame.width) / 2, 0),
            bottom: 0,
            right: 0
        )
    }
}
//MARK: for close pan gesture
extension ImagePageView {

    enum CloseDirection {
        case up
        case down
    }

    private func setupClosePanGesture() {
        // スワイプ開始時の位置を格納
        var startPanPointY: CGFloat = 0.0
        // スワイプ開始時の位置とImageViewのCenterの距離を格納
        var distanceY: CGFloat = 0.0
        // 画面を閉じるラインの設定　（画面高さの1/6の距離を移動したら）
        let moveAmountYCloseLine: CGFloat = view.bounds.height / 6
        let minBackgroundAlpha: CGFloat = 0.5
        let maxBackgroundAlpha: CGFloat = 1.0

        let panGesture = UIPanGestureRecognizer(target: self, action: nil)
        panGesture.rx.event
            .subscribe(onNext: { [weak self] sender in
                guard let strongSelf = self else { return }

                let currentPointY = sender.location(in: strongSelf.view).y

                switch sender.state {
                case .began:
                    // スワイプを開始したら呼ばれる １回だけ
                    startPanPointY = currentPointY
                    distanceY = strongSelf.mainScrollView.center.y - startPanPointY
                    strongSelf.updateHeaderFooterView(isHidden: true)
                case .changed:
                    // スワイプ中呼ばれる　移動するたび
                    // ImageViewの移動
                    let calcedImageViewPosition = CGPoint(x: strongSelf.view.bounds.width / 2, y: distanceY + currentPointY)
                    strongSelf.mainScrollView.center = calcedImageViewPosition
                    // 背景の透明度更新
                    let moveAmountY = abs(currentPointY - startPanPointY)
                    var backgroundAlpha = moveAmountY / (-moveAmountYCloseLine) + 1
                    if backgroundAlpha > maxBackgroundAlpha {
                        backgroundAlpha = maxBackgroundAlpha
                    } else if backgroundAlpha < minBackgroundAlpha {
                        backgroundAlpha = minBackgroundAlpha
                    }
                    strongSelf.view.backgroundColor = strongSelf.view.backgroundColor?.withAlphaComponent(backgroundAlpha)

                    strongSelf.closeButton.tintColor = .clear
                    strongSelf.editButton.tintColor = .clear
                    strongSelf.shareButton.tintColor = .clear
                    
                case .ended:
                    // 指を離すと呼ばれる
                    let moveAmountY = currentPointY - startPanPointY
                    let isCloseTop = moveAmountY > moveAmountYCloseLine
                    let isCloseBottom = moveAmountY < moveAmountYCloseLine * -1
                    if isCloseTop {
                        strongSelf.dismiss(animateDuration: 0.15, direction: .up)
                        return
                    }
                    if isCloseBottom {
                        strongSelf.dismiss(animateDuration: 0.15, direction: .down)
                        return
                    }
                    UIView.animate(withDuration: 0.25, animations: {
                        strongSelf.mainScrollView.center = strongSelf.view.center
                        strongSelf.view.backgroundColor = strongSelf.view.backgroundColor?.withAlphaComponent(1.0)
                        strongSelf.closeButton.tintColor = R.color.mainWhite()!
                        strongSelf.editButton.tintColor = R.color.mainWhite()!
                        strongSelf.shareButton.tintColor = R.color.mainWhite()!
                    })
                    strongSelf.updateHeaderFooterView(isHidden: false)
                default: break
                }
            })
            .disposed(by: disposeBag)
        self.view.addGestureRecognizer(panGesture)
    }

    private func dismiss(animateDuration: TimeInterval, direction: CloseDirection) {
        let imageViewCenterPoint: CGPoint = {
            switch direction {
            case .up:
                return CGPoint(x: view.bounds.width / 2, y: view.bounds.height + mainScrollView.bounds.height)
            case .down:
                return CGPoint(x: view.bounds.width / 2, y: -mainScrollView.bounds.height)
            }
        }()
        UIView.animate(withDuration: animateDuration, animations: { [weak self] in
            self?.view.backgroundColor = self?.view.backgroundColor?.withAlphaComponent(0.0)
            self?.mainScrollView.center = imageViewCenterPoint
            }, completion: { [weak self] _ in
                self?.dismiss(animated: false, completion: nil)
        })
    }

    // Twitterでいう、「リプライ」「お気に入り」などがあるViewの表示制御処理
    private func updateHeaderFooterView(isHidden: Bool) {
    }
}
//MARK: for image crop view
extension ImagePageView: CropViewControllerDelegate, UIImagePickerControllerDelegate{
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {

        self.delegate?.editImage(of: image,index: calculatePage(of: mainScrollView))

        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }

    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        currentPage = calculatePage(of: mainScrollView)
        let subScrollView = mainScrollView.subviews[currentPage] as! UIScrollView
        let imageView = subScrollView.subviews[0] as! UIImageView
        imageView.image = image

        cropViewController.dismiss(animated: true, completion: nil)
    }
}
