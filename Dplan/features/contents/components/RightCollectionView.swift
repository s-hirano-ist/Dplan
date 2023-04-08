//
//  MainSectionViewController.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/29.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import Material
import SnapKit

class RightCollectionView: UIViewController {
    let s = Settings()
    let d = RealmPlan()
    let o = RealmOthers()

    lazy var collectionView :UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 40)
        //let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    lazy var bottomView:UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemGray5
        return backgroundView
    }()

    var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    lazy var toMainViewButton: RaisedButton = {
        let button = s.raisedButton()
        button.tintColor = R.color.mainBlack()!
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(showMainViewClicked(gestureRecognizer:))))
        return button
    }()
    @objc func showMainViewClicked(gestureRecognizer:UIGestureRecognizer) {
        if let view = self.presentingViewController as? MainBackgroundView {
            view.updateMainView()
            self.dismiss(animated: true, completion: nil)
        }
    }

    var showAllNotes = true
    var showAllWebsites = true
    var showAllPlaces = true
    var showAllImages = true

    var data:[ListDiffable] = []
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(),
                           viewController: self,
                           workingRangeSize: 2)
        //working range size = number of pages loaded outside of self.frame
    }()
    var placeView:PlaceLocationView = {
        let view = PlaceLocationView()
        view.modalPresentationStyle = .overFullScreen
        return view
    }()

    func placeLocationSegue(in row:Int,state:State){
        placeView.rows = row //適当な値．
        placeView.state = state
        self.present(placeView, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = R.color.mainWhite()!
        adapter.collectionView = collectionView
        adapter.dataSource = self
        setConstraints()
    }
    private func setConstraints(){
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        bottomView.addSubview(titleLabel)
        bottomView.addSubview(toMainViewButton)

        collectionView.snp.makeConstraints({ (make) -> Void in
            make.right.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(toMainViewButton.snp.top).offset(-8)
        })
        bottomView.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(44)
            make.left.right.equalToSuperview()
        })

        toMainViewButton.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(44)
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
        })
        titleLabel.snp.makeConstraints({(make) -> Void in
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(44)
            make.right.equalToSuperview().offset(-56)
            make.left.equalTo(toMainViewButton.snp.right)
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        adapter.performUpdates(animated: true, completion: nil)
        titleLabel.text = d.getTitle(at:NUMBER)
    }
}
extension RightCollectionView: ListAdapterDataSource {

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        data = []

        data += [2] as [ListDiffable] // notes header
        data += [d.eachPlanData()] as [ListDiffable]

        data += o.countWebsites()==0 ? [6] as [ListDiffable] : [0] as [ListDiffable]
        if showAllWebsites {
            data += o.websites().map({$0 as ListDiffable})
        }else{
            //IMPROVE
        }
        data += o.countPlaces()==0 ? [7] as [ListDiffable] : [1] as [ListDiffable]
        if showAllPlaces {
            data += o.place().map({$0 as ListDiffable})
        }else {
            //data += o.place().filter({$0.isFavorite == true }) as [ListDiffable]
        }
        let i = Images()
        //images of plans
        for section in 0 ..< RealmPlan().countDays(at: NUMBER) {
            for row in 0 ..< RealmPlan().countDestination(at: NUMBER, in: section){
                for image in RealmPlan().data(at: section, row).imageList {
                    if image.image != nil {
                        i.imageArray.append(image)
                    }
                }
            }
        }
        //images of places
        for row in 0 ..< RealmOthers().countPlaces(){
            for image in RealmOthers().place()[row].imageList {
                if image.image != nil {
                    i.imageArray.append(image)
                }
            }
        }
        data += i.imageArray.count==0 ? [8] as [ListDiffable] : [3] as [ListDiffable]
        data += [i] as [ListDiffable]
        return data
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any)-> ListSectionController {
        switch object {
        case is Int:
            let controller = HeaderSectionController()
//            controller.delegate = self
            return controller
        case is URLData:
            let controller = OthersWebsiteSectionController()
            controller.delegate = self
            return controller
        case is Plan:
            return NotesSectionController()
        case is Images:
            let controller = ImageSectionController()
            controller.delegate = self
            return controller
        case is PlaceData:
            let controller = PlaceFlatSectionController()
            controller.delegate = self
            return controller
        default:
            ERROR("ERROR IN SECTION CONTROLLER SELECTION")
            return ListSectionController()
        }
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
extension RightCollectionView: PlaceFlatSectionDelegate {
    func placeFavoriteButtonPressed(at row: Int) {

    }
    func placeShareButtonPressed(at row: Int) {
        
    }
    func placePressed(at row: Int) {
        placeLocationSegue(in: row, state: .show)
    }
    func placeReload() {
        adapter.performUpdates(animated: true, completion: nil)
    }
}

extension RightCollectionView{
    func showAllButtonClicked(at row: Int) {
        switch row {
        case 0: //website
            //showAllWebsites.toggle()
            break
        case 1: //candidate
            //showAllPlaces.toggle()
            break
        case 2: //notes
            //showAllNotes.toggle()
            break
        case 3: //images
            //showAllImages.toggle()
            break
        case 4: //plans
            break
        default:
            break
        }
        //adapter.performUpdates(animated: true, completion: nil)
    }

    func showMapButtonClicked(at row: Int) {
        print("showMap")
    }
}
extension RightCollectionView:ImageSectionDelegate {
    func imageClicked(at row: Int,imageData:[UIImage?]) {
        let view = R.storyboard.main.imagepagE()!
        view.images = []
        for image in imageData {
            if let image = image {
                view.images.append(image)
            }
        }
        view.currentPage = row
        view.canDelete = false
        view.modalPresentationStyle = .overFullScreen
        present(view, animated: true, completion: nil)
    }
}
extension RightCollectionView: OthersWebsiteSectionDelegate {
    func websiteClicked(at row: Int) {
        Segues().websiteSegue(in: row,
                              state: .editURL,
                              controller: self)
    }
    func webCellReload() {
        adapter.performUpdates(animated: true, completion: nil)
    }
}


/*
extension RightCollectionView: HorizontalSectionDelegate{
    func placeClicked(at row: Int) {
        Segues().placeLocationSegue(in: row, state: .show, controller: self)
    }
}
*/
