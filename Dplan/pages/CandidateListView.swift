//
//  CandidateListView.swift
//  DraPla05
//
//  Created by Soraki Hirano on 2022/12/31.
//  Copyright © 2022 Sola Studio. All rights reserved.
//

import UIKit
//import IGListKit
//import SnapKit
import Material

class CandidateListView: UIViewController {
    
    private func prepareCandidateFABMenuItem() {
        let button = FABButton(image: Icon.cm.share, tintColor: R.color.mainGray()! )
//        placeFabMenuItem.title = "Add place".localized
//        Settings().prepareFabMenuItemColors(item: placeFabMenuItem, icon: Icon.icon("ic_add_white"), backgroundColor: R.color.mainGray()!)
//        placeFabMenuItem.fabButton.addTarget(self, action: #selector(handleCandidateFABMenuItem(button:)), for: .touchUpInside)
    }
    @objc fileprivate func handleCandidateFABMenuItem(button: UIButton) {
        if let mainView = self.children[0] as? PlanListView{
            mainView.candidateView.rows = RealmCandidate().place().count
            RealmCandidate().saveCandidate()
            mainView.candidateView.state = .new
            mainView.present(mainView.candidateView, animated: true, completion: nil)
        }
    }
}
