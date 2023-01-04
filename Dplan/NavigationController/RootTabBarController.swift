//
//  RootTabBarController.swift
//  Dplan
//
//  Created by S.Hirano.
//  Copyright © 2022 Sola Studio. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        let planListView = PlanListView()
        planListView.tabBarItem = UITabBarItem(title: "Plans".localized, image: .mappin, tag: 0)
        
        let candidateListView = CandidateListView()
        candidateListView.tabBarItem = UITabBarItem(title: "Places".localized, image: .bookmark, tag: 1)

        let websiteListView = CandidateListView()
        websiteListView.tabBarItem = UITabBarItem(title: "Websites".localized, image: .paperPlane, tag: 2)
        
        viewControllers = [planListView, candidateListView, websiteListView]
    }
}
