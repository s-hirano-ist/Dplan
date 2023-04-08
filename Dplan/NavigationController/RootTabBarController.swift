//
//  RootTabBarController.swift
//  Dplan
//
//  Created by S.Hirano.
//  Copyright © 2023 Sola Studio. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        let planListView = PlanListView()
        planListView.tabBarItem = UITabBarItem(title: "Plans".localized, image: .mappin, tag: 0)
        
        //TODO: from HERE
        let candidateListView = CandidateListView()
        candidateListView.tabBarItem = UITabBarItem(title: "Places".localized, image: .bookmark, tag: 1)
        
        let websiteListView = WebsiteListView()
        websiteListView.tabBarItem = UITabBarItem(title: "Websites".localized, image: .globe, tag: 2)
        
        viewControllers = [planListView, candidateListView, websiteListView]
    }
}
