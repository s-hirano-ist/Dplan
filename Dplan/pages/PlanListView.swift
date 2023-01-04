//
//  SideCollectionView.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/30.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit
import Material

class PlanListView: UIViewController {
    let d = RealmPlan()
    let s = Settings()
    
    var showAllPlans = true
    
    var mainView = {
        let view = MainBackgroundView()
        view.modalPresentationStyle = .fullScreen
        return view
    }()
    
    var topBarView = TopBarView()
    var bannerView = BannerView()
    lazy var collectionView :UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 40)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private var data:[ListDiffable] = []
    lazy private var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(),
                           viewController: self,
                           workingRangeSize: 2)
    }()
    
}
//MARK: on first load
extension PlanListView {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = R.color.mainWhite()!
        
//        if c.countData() == 0 {
//            print("Add empty data to prevent data undefined")
//            c.addEmptyData()
//        }
        setConsraints()
        adapter.collectionView = collectionView
        adapter.dataSource = self
        topBarView.delegate = self
    }
    func setConsraints(){
        view.addSubview(topBarView)
        view.addSubview(bannerView)
        view.addSubview(collectionView)
        
        topBarView.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
        })
        bannerView.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(topBarView.snp.bottom)
            make.right.left.equalToSuperview()
        })
        collectionView.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(bannerView.snp.bottom)
            make.right.left.equalToSuperview()
            make.bottom.equalToSuperview()
        })
    }
    
}//MARK: on every view appear
extension PlanListView {
    override func viewWillAppear(_ animated: Bool) {
        adapter.performUpdates(animated: true, completion: nil)
    }
}

extension PlanListView: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        data = []
        data += d.countPlans() == 0 ? [5] as [ListDiffable] :[4] as [ListDiffable] //plan header
        if showAllPlans {
            data += (0..<d.countPlans()).map { d.planList()[$0]  as ListDiffable }
        }else{
            //data += d.planList().filter({$0.isFavorite == true}) as [ListDiffable]
        }
        
//        if c.countData() >= 1 {
//            data += c.countWebsite() == 0 ? [6] as [ListDiffable] :[0] as [ListDiffable] //website Header
//            if showAllWebsites {
//                data += c.website().map({$0 as ListDiffable})
//            }else{
//                //MARK: IMPROVE
//            }
//            /*data += [2] as [ListDiffable] //notes
//             for note in c.text() {
//             data += [note] as [ListDiffable]
//             }*/
//            data += c.countCandidate()==0 ? [7] as [ListDiffable] : [1] as [ListDiffable] //candidate header
//            if showAllPlaces{
//                data += (0..<c.countCandidate()).map { c.place()[$0]  as ListDiffable }
//            }else{
//                //MARK: IMPROVE data += c.place().filter({$0.isFavorite == true }) as [ListDiffable]
//            }
//
//        }else{
//            ERROR("ERROR IN COUNT DATA == 0")
//            return [] as [ListDiffable]
//        }
        return data
    }
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any)-> ListSectionController {
        switch object {
        case is Int:
            let controller = HeaderSectionController()
            // MARK: HeaderSection有効化でコメントイン
            //            controller.delegate = self
            return controller
        case is URLData:
            let controller = CandidateWebsiteSectionController()
            controller.delegate = self
            return controller
            /*case is SectionState:
             let controller = HorizontalSectionController()
             controller.delegate = self
             return controller*/
        case is Plan:
            let controller = PlanFlatSectionController()
            controller.delegate = self
            return controller
        case is PlaceData:
            let controller = CandidateFlatSectionController()
//            controller.delegate = self
            return controller
            /*case is TextData:
             return NotesSectionController()*/
        default:
            ERROR("ERROR IN SECTION CONTROLLER SELECTION")
            return ListSectionController()
        }
    }
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension PlanListView: PlanFlatSectionDelegate {
    func candidateReload() {
        adapter.performUpdates(animated: true, completion: nil)
    }
    //MARK: for delete,add pin
    func planReload() {
        adapter.performUpdates(animated: true, completion: nil)
    }
    
    func planPressed(at row: Int) {
        NUMBER = row
        self.present(mainView, animated: true, completion: nil)
    }
    
    func planShareButtonPressed(at row: Int) {
    }
    func planFavoriteButtonPressed(at row: Int) {
    }
    func candidateShareButtonPressed(at row: Int) {
    }
    func candidateFavoriteButtonPressed(at row: Int) {
    }
}
extension PlanListView: TopBarViewDelegate{
    func addNewPlan() {
        NUMBER = RealmPlan().countPlans()
        RealmPlan().saveNewPlan()
        present(mainView, animated: false, completion: { [self] in
            self.mainView.collectionView.presentPlanLocationView(at: 0, 0, state: .newPlan)
        })
    }
    func showSettings() {
        print("Settings button clicked")
    }
}

extension PlanListView:CandidateWebsiteSectionDelegate{
    func websiteClicked(at row: Int) {
        Segues().websiteSegue(in: row, state: .editURLCandidate, controller: self)
    }
    func webCellReload() {
        adapter.performUpdates(animated: true, completion: nil)
    }
}


/*
 extension SideCollectionView:HorizontalSectionDelegate {
 func planClicked(at row: Int) {
 NUMBER = row
 let parent = self.presentingViewController as! MainBackgroundView
 parent.updateView()
 self.dismiss(animated: true, completion: nil)
 }
 
 func placeClicked(at row: Int) {
 print(row)
 Segues().candidateLocationSegue(in: row, state: .show, controller: self)
 }
 }
 */

/*
 // MARK: IMPROVE disable now Delegate有効化忘れずに
 extension SideCollectionView: HeaderSectionDelegate {
 func showAllButtonClicked(at row: Int) {
 print("show all")
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
 break
 case 4: //plans
 //showAllPlans.toggle()
 break
 default:
 break
 }
 }
 func showMapButtonClicked(at row: Int) {
 print("show map")
 }
 }
 */
