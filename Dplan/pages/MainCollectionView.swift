//
//  MainCollectionView.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/04/01.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import FloatingPanel
import Material
import MapKit
import IGListKit
import SwipeCellKit
import SnapKit
//import GoogleMobileAds

protocol MainCollectionViewDelegate {
    func showTimePicker(at section:Int,_ row:Int) -> Void
    func dismissActivate()->Void
    func timeClicked(at section:Int,_ row:Int)->Void
    func reloadView()->Void
}

class MainCollectionView: UIViewController  {
    private let s = Settings()
    private let d = RealmPlan()
    var delegate :MainCollectionViewDelegate?
    var data:[ListDiffable] = []

    var planLocationView: PlanLocationView = {
        let view = PlanLocationView()
        view.modalPresentationStyle = .fullScreen
        return view
    }()

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(),
                           viewController: self,
                           workingRangeSize: 2)
    }()

    var blurView: UIVisualEffectView!

    lazy var collectionView :UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.frame = CGRect(x: 0,
                                 y: 50,
                                 width: view.frame.width,
                                 height: (halfPositionHeight ?? 300) - bottomBarHeight - 50)
        return collectionView
    }()

    lazy var titleField: UITextField = {
        let textField = s.textField()
        textField.font = .systemFont(ofSize: 25, weight: .heavy)
        textField.textColor = R.color.mainBlack()!
        textField.adjustsFontSizeToFitWidth = true
        textField.delegate = self
        textField.isEnabled = false
        return textField
    }()

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = R.color.mainBlack()!
        label.isUserInteractionEnabled = true
         label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dateLabelClicked(gestureRecognizer:))))
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        return label
    }()
    //MARK: IMPROVE date picker activate
    @objc func dateLabelClicked(gestureRecognizer: UITapGestureRecognizer) {

    }
    //MARK: IMPROVE DISABLED NOW
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(.share,for: .normal)
        button.tintColor = R.color.mainBlack()!
        button.contentHorizontalAlignment = .right
        button.isHidden = false
        button.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)
        return button
    }()
    @objc func shareButtonPressed(_ sender: UIButton) {
        Segues().sharePlanSegue(controller: self,num: NUMBER)
    }

    lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = R.color.mainBlack()!
        return line
    }()
    func reloadLabel(){
        titleField.text = d.getTitle(at: NUMBER)
        dateLabel.text = d.getDatePeriod(at: NUMBER)
    }
    let edgeInsets = UIEdgeInsets(top: 20, left: 16, bottom: 16, right: 16)

}
extension MainCollectionView {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = R.color.mainWhite()!
        view.addSubview(titleField)
        view.addSubview(dateLabel)
        view.addSubview(shareButton)
        view.addSubview(line)
        view.addSubview(collectionView)

        setConstraints()

        setBlurEffect() //activate at last
        setRefreshSelector()
        reloadLabel()
        adapter.collectionView = collectionView
        adapter.moveDelegate = self
        adapter.dataSource = self
    }
    private func setConstraints(){
        dateLabel.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(32)
            make.top.equalToSuperview().offset(edgeInsets.top)
            make.right.equalTo(shareButton.snp.left)
            make.width.equalTo(getThirdWidthBlock())
        })
        shareButton.snp.makeConstraints({ (make) -> Void in
            make.right.equalToSuperview().offset(-edgeInsets.left)
            make.top.equalToSuperview().offset(edgeInsets.top)
            //make.size.equalTo(32)
            make.height.equalTo(32)
            make.width.equalTo(32)
        })
        titleField.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview().offset(edgeInsets.left)
            make.right.equalTo(dateLabel.snp.left).offset(8)
            make.top.equalToSuperview().offset(edgeInsets.top)
            make.height.equalTo(32)
        })
        line.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(50)
            make.width.equalToSuperview()
            make.height.equalTo(0.67)
        })
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        titleField.isEnabled = editing
    }
    override func viewWillAppear(_ animated: Bool) {
//        print("collectionViewwillAppear")
    }
}

//MARK: for IGListKit dataSource
extension MainCollectionView:ListAdapterDataSource,ListAdapterMoveDelegate {

    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            let touchLocation = gesture.location(in: self.collectionView)
            guard let selectedIndexPath = collectionView.indexPathForItem(at: touchLocation) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            if let view = gesture.view {
                let position = gesture.location(in: view)
                collectionView.updateInteractiveMovementTargetPosition(position)
            }
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

    func listAdapter(_ listAdapter: ListAdapter, move object: Any, from previousObjects: [Any], to objects: [Any]) {
        guard let objects = objects as? [ListDiffable] else { return }
        data = objects
    }

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        data = []
        for (index,plan) in d.plan().enumerated() {
            if !isEditing {
                data += [index] as [ListDiffable]
            }
            data += [plan] as [ListDiffable]
        }
        return data
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any)-> ListSectionController {
        if object is Int {
            let controller = MainHeaderSectionController()
            controller.delegate = self
            return controller
        }
        if isEditing {
            let controller = EditSectionController()
            controller.delegate = self
            return controller
        }else{
            let controller = NonEditSectionController()
            controller.delegate = self
            return controller
        }
    }
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

//MARK: for activation
extension MainCollectionView: NonEditSectionDelegate,EditSectionDelegate,MainHeaderSectionDelegate {
    func headerClicked(at row: Int) {
        DEBUG("headerClicked")
        //MARK: IMPROVE 格納
    }
    //MARK: アップデート
    @objc func refreshTable() {
        d.reload(completion:{
            self.delegate?.reloadView()
            self.collectionView.refreshControl?.endRefreshing()
        })
    }
    func reloadFromEdit() {
        d.reload(completion: {
            self.delegate?.reloadView()
        })
    }
    func dismissFromDelete() {
        d.reload(completion: {
            self.delegate?.dismissActivate()
        })
    }
    func editPlaceClicked(at section: Int, _ row: Int) {
        presentPlanLocationView(at: section, row, state: .edit)
    }
    func placeClicked(at section: Int, _ row: Int) {
        presentPlanLocationView(at: section, row, state: .show)
    }
    func timeClicked(at section: Int, _ row: Int) {
        self.delegate?.timeClicked(at: section, row)
    }
    func timePickerActivate(at section: Int, _ row: Int) {
        self.delegate?.showTimePicker(at: section, row)
    }

    func presentPlanLocationView(at section:Int,_ row:Int,state: PlanState){
        planLocationView.sections = section
        planLocationView.rows = row
        planLocationView.state = state
        self.present(planLocationView, animated: true, completion: nil)
    }
}

extension MainCollectionView {
    private func getThirdWidthBlock()->CGFloat{
        return (view.frame.width - edgeInsets.left - edgeInsets.right)/3
    }
    func setRefreshSelector(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = R.color.mainBlack()!
        collectionView.refreshControl = refreshControl
    }
    //MARK: NEED TO BE AFTER ALL LAYOUTS
    private func setBlurEffect(){
        blurView = UIVisualEffectView()
        blurView.effect = UIBlurEffect(style: .systemChromeMaterial)
        //MARK: blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight] これは何?
        blurView.frame = view.frame
        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)
    }
}
extension MainCollectionView :UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text{
            RealmPlan().setTitle(at: NUMBER, to: text)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
