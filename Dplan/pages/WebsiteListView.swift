//
//  WebsiteListView.swift
//  DraPla05
//
//  Created by Soraki Hirano on 2022/12/31.
//  Copyright © 2022 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit
import Material

class WebsiteListView: UIViewController {
    private func prepareWebsiteFABMenuItem() {
        let button = FABButton(image: Icon.cm.share, tintColor: R.color.mainGray()! )
//        websiteFabMenuItem.title = "Add website".localized
//        Settings().prepareFabMenuItemColors(item: websiteFabMenuItem, icon: Icon.icon("ic_add_white"), backgroundColor: R.color.mainGray()!)
//        websiteFabMenuItem.fabButton.addTarget(self, action: #selector(handleWebsiteFABMenuItem(button:)), for: .touchUpInside)
    }
    @objc fileprivate func handleWebsiteFABMenuItem(button: UIButton) {
        if let mainView = self.children[0] as? PlanListView{
            //MARK: IMPROVE メモリリーク関連? ここの定義できていない webViewの方
            Segues().websiteSegue(in: RealmCandidate().countWebsite(),
                                  state: .newURLCandidate,
                                  controller: mainView)
        }
    }
}
