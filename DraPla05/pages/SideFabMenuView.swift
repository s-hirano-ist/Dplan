//
//  SideFabMenuView.swift
//  DraPla05
//
//  Created by S.Hirano on 2019/12/14.
//  Copyright © 2019 Sola_studio. All rights reserved.
//

import UIKit
import Material

class SideFabMenuView: FABMenuController {
    
    private var fabButton:FABButton = {
        let fabButton = FABButton(image: Icon.icon("ic_add_white"), tintColor: R.color.mainCyan()!)
//        fabButton.backgroundColor = R.color.subNavy()!
//        fabButton.pulseColor = R.color.mainWhite()!
        return fabButton
    }()
    private var planFABMenuItem:FABMenuItem!
    private var placeFabMenuItem: FABMenuItem!
    private var websiteFabMenuItem: FABMenuItem!

    var planLocationView: PlanLocationView = {
        let view = PlanLocationView()
        view.modalPresentationStyle = .fullScreen
        return view
    }()
    
    lazy var addButton: FABButton = {
        let button = FABButton(image: Icon.cm.share, tintColor: R.color.mainGray()! )
        button.pulseColor = R.color.mainWhite()!
        button.image = Icon.icon("ic_add_white")
        button.tintColor = R.color.mainWhite()!
        button.backgroundColor = R.color.subNavy()!
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addButtonPressed(gestureRecognizer:))))
        return button
    }()
    @objc func addButtonPressed(gestureRecognizer:UIGestureRecognizer) {
        print("ADD BUTTON PRESSED")
    }
    
    open override func prepare() {
        super.prepare()
        
        preparePlanFabMenuItem()
        prepareCandidateFABMenuItem()
        prepareWebsiteFABMenuItem()

        view.backgroundColor = .clear
        fabMenu.fabButton = fabButton
        fabMenu.fabMenuItems = [planFABMenuItem, placeFabMenuItem, websiteFabMenuItem]
        view.addSubview(fabMenu)
        
        view.addSubview(addButton)
        addButton.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(56)
            make.right.bottom.equalToSuperview().offset(-16)
        })

        fabMenu.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(56)
            make.right.bottom.equalToSuperview().offset(-16)
        })
    }
}

// MARK: ボタン類の作成と画面遷移
extension SideFabMenuView {
    
    private func preparePlanFabMenuItem(){
        planFABMenuItem = FABMenuItem()
        planFABMenuItem.title = "Make new plan".localized
        Settings().prepareFabMenuItemColors(item: planFABMenuItem, icon: Icon.cm.pen, backgroundColor: R.color.mainGray()!)
        planFABMenuItem.fabButton.addTarget(self, action: #selector(handlePlanFABMenuItem(button:)), for: .touchUpInside)
    }
    @objc fileprivate func handlePlanFABMenuItem(button: UIButton) {
        if let mainView = self.children[0] as? SideCollectionView{
            print("COUNT　PLANS")
            NUMBER = RealmPlan().countPlans()
            print("NUMBER", NUMBER)
            RealmPlan().saveNewPlan()
            print("SAVE　DONE")
            
            present(mainView.mainView, animated: false, completion: {
                mainView.mainView.collectionView.presentPlanLocationView(at: 0, 0, state: .newPlan)
            })
        }
        fabMenu.close()
        fabMenu.fabButton?.animate(.rotate(0))
    }
    
    private func prepareCandidateFABMenuItem() {
        placeFabMenuItem = FABMenuItem()
        placeFabMenuItem.title = "Add place".localized
        Settings().prepareFabMenuItemColors(item: placeFabMenuItem, icon: Icon.icon("ic_add_white"), backgroundColor: R.color.mainGray()!)
        placeFabMenuItem.fabButton.addTarget(self, action: #selector(handleCandidateFABMenuItem(button:)), for: .touchUpInside)
    }
    @objc fileprivate func handleCandidateFABMenuItem(button: UIButton) {
        if let mainView = self.children[0] as? SideCollectionView{
            mainView.candidateView.rows = RealmCandidate().place().count
            RealmCandidate().saveCandidate()
            mainView.candidateView.state = .new
            mainView.present(mainView.candidateView, animated: true, completion: nil)
        }
        fabMenu.close()
        fabMenu.fabButton?.animate(.rotate(0))
    }
    
    private func prepareWebsiteFABMenuItem() {
        websiteFabMenuItem = FABMenuItem()
        websiteFabMenuItem.title = "Add website".localized
        Settings().prepareFabMenuItemColors(item: websiteFabMenuItem, icon: Icon.icon("ic_add_white"), backgroundColor: R.color.mainGray()!)
        websiteFabMenuItem.fabButton.addTarget(self, action: #selector(handleWebsiteFABMenuItem(button:)), for: .touchUpInside)
    }
    @objc fileprivate func handleWebsiteFABMenuItem(button: UIButton) {
        if let mainView = self.children[0] as? SideCollectionView{
            //MARK: IMPROVE メモリリーク関連? ここの定義できていない webViewの方
            Segues().websiteSegue(in: RealmCandidate().countWebsite(),
                                  state: .newURLCandidate,
                                  controller: mainView)
        }
        fabMenu.close()
        fabMenu.fabButton?.animate(.rotate(0))
    }
}

// MARK: FABボタンを押したときの動作
extension SideFabMenuView {
    @objc open func fabMenuWillOpen(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(.rotate(45))
    }

    @objc open func fabMenuDidOpen(fabMenu: FABMenu) {
    }

    @objc open func fabMenuWillClose(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(.rotate(0))
    }

    @objc open func fabMenuDidClose(fabMenu: FABMenu) {
    }

    @objc open func fabMenu(fabMenu: FABMenu, tappedAt point: CGPoint, isOutside: Bool) {
        guard isOutside else {
            return
        }
    }
}
