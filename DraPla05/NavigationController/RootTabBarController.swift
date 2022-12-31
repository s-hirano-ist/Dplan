//
//  SideFabMenuView.swift
//  DraPla05
//
//  Created by S.Hirano on 2022/12/14.
//  Copyright © 2022 Sola_studio. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        let planListView = PlanListView()
        planListView.tabBarItem = UITabBarItem(title: "Add plan".localized, image: .mappin, tag: 0)
        
        let candidateListView = CandidateListView()
        candidateListView.tabBarItem = UITabBarItem(title: "Add place".localized, image: .bookmark, tag: 1)

        let websiteListView = CandidateListView()
        websiteListView.tabBarItem = UITabBarItem(title: "Add website".localized, image: .paperPlane, tag: 2)
        
        viewControllers = [planListView, candidateListView, websiteListView]
    }
}
