//
//  CandidateListView.swift
//  Dplan
//
//  Created by Soraki Hirano on 2022/12/31.
//  Copyright © 2022 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit
import Material

//extension PlanListView: ListAdapterDataSource {
//    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
//        data = []
//        data += d.countPlans() == 0 ? [5] as [ListDiffable] :[4] as [ListDiffable] //plan header
//        data += (0..<d.countPlans()).map { d.planList()[$0]  as ListDiffable }
//        return data
//    }
//    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any)-> ListSectionController {
//        switch object {
//        case is Int:
//            return HeaderSectionController()
//        case is URLData:
//            let controller = CandidateWebsiteSectionController()
//            //            controller.delegate = self
//            return controller
//        case is Plan:
//            let controller = PlanFlatSectionController()
//            controller.delegate = self
//            return controller
//        case is PlaceData:
//            let controller = CandidateFlatSectionController()
//            //            controller.delegate = self
//            return controller
//        default:
//            ERROR("ERROR IN SECTION CONTROLLER SELECTION")
//            return ListSectionController()
//        }
//    }
//    func emptyView(for listAdapter: ListAdapter) -> UIView? {
//        return nil
//    }
//}
//

class CandidateListView: ListViewController {
    let c = RealmCandidate()
    let s = Settings()
        
    var candidateView:CandidateLocationView = {
        let view = CandidateLocationView()
        view.modalPresentationStyle = .fullScreen
        return view
    }()
    
    
    private func prepareCandidateFABMenuItem() {
        //        let button = FABButton(image: Icon.cm.share, tintColor: R.color.mainGray()! )
        
        
        //        placeFabMenuItem.title = "Add place".localized
        //        Settings().prepareFabMenuItemColors(item: placeFabMenuItem, icon: Icon.icon("ic_add_white"), backgroundColor: R.color.mainGray()!)
        //        placeFabMenuItem.fabButton.addTarget(self, action: #selector(handleCandidateFABMenuItem(button:)), for: .touchUpInside)
    }
    @objc fileprivate func handleCandidateFABMenuItem(button: UIButton) {
        //        if let mainView = self.children[0] as? PlanListView{
        //            mainView.candidateView.rows = RealmCandidate().place().count
        //            RealmCandidate().saveCandidate()
        //            mainView.candidateView.state = .new
        //            mainView.present(mainView.candidateView, animated: true, completion: nil)
        //        }
    }
    
    func a() {
        //        if c.countData() >= 1 {
        //            data += c.countWebsite() == 0 ? [6] as [ListDiffable] :[0] as [ListDiffable] //website Header
        //            if showAllWebsites {
        //                data += c.website().map({$0 as ListDiffable})
        //            }else{
        //                //IMPROVE
        //            }
        //            /*data += [2] as [ListDiffable] //notes
        //             for note in c.text() {
        //             data += [note] as [ListDiffable]
        //             }*/
        //            data += c.countCandidate()==0 ? [7] as [ListDiffable] : [1] as [ListDiffable] //candidate header
        //            if showAllPlaces{
        //                data += (0..<c.countCandidate()).map { c.place()[$0]  as ListDiffable }
        //            }else{
        //                //IMPROVE data += c.place().filter({$0.isFavorite == true }) as [ListDiffable]
        //            }
        //
        //        }else{
        //            ERROR("ERROR IN COUNT DATA == 0")
        //            return [] as [ListDiffable]
        //        }
    }
}
//on first load
extension CandidateListView {
    override func viewDidLoad() {
        super.viewDidLoad()
        //        adapter.dataSource = self
        //        adapter.collectionView = collectionView
        //        topBarView.delegate = self
        //        if c.countData() == 0 {
        //            print("Add empty data to prevent data undefined")
        //            c.addEmptyData()
        //        }
    }
    
}//on every view appear
extension CandidateListView {
    override func viewWillAppear(_ animated: Bool) {
        adapter.performUpdates(animated: true, completion: nil)
    }
}

extension CandidateListView: CandidateFlatSectionDelegate {
    func candidateShareButtonPressed(at row: Int) {
        
    }
    
    func candidateFavoriteButtonPressed(at row: Int) {
        
    }
    
    func candidateReload() {
        adapter.performUpdates(animated: true, completion: nil)
    }
    
    func candidatePressed(at row: Int) {
        candidateView.rows = row
        candidateView.state = .show
        present(candidateView, animated: true, completion: nil)
    }
}

extension CandidateListView: CandidateWebsiteSectionDelegate{
    func websiteClicked(at row: Int) {
        Segues().websiteSegue(in: row, state: .editURLCandidate, controller: self)
    }
    func webCellReload() {
        adapter.performUpdates(animated: true, completion: nil)
    }
}

/* TODO: WHAT IS THIS
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

