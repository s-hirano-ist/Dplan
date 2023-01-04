//
//  SideCollectionView.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/30.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import Material

class PlanListView: ListViewController {
    let d = RealmPlan()
    let s = Settings()
    
    var mainView = {
        let view = MainBackgroundView()
        view.modalPresentationStyle = .fullScreen
        return view
    }()
    
    private var data:[ListDiffable] = []
    
}
//MARK: on first load
extension PlanListView {
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.dataSource = self
        adapter.collectionView = collectionView
        topBarView.delegate = self
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
        data += d.countPlans() == 0 ? [5] as [ListDiffable] :[4] as [ListDiffable] //header
        data += (0..<d.countPlans()).map { d.planList()[$0]  as ListDiffable }
        return data
    }
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any)-> ListSectionController {
        switch object {
        case is Int:
            return HeaderSectionController()
        case is Plan:
            let controller = PlanFlatSectionController()
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

extension PlanListView: PlanFlatSectionDelegate {
    //MARK: for delete, add pin
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
