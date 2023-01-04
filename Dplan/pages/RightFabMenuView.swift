//
//  RightFabMenuView.swift
//  DraPla05
//
//  Created by S.Hirano on 2019/12/30.
//  Copyright © 2019 Sola Studio. All rights reserved.
//

import UIKit
import Material
import Motion
import SnapKit

class RightFabMenuView: FABMenuController {
    private let fabMenuSize = CGSize(width: 56, height: 56)
    private let bottomInset: CGFloat = 24
    private let rightInset: CGFloat = 24

    private var fabButton: FABButton!
    private var urlFABMenuItem: FABMenuItem!
    private var placeFABMenuItem: FABMenuItem!
    let s = Settings()

    open override func prepare() {
        super.prepare()
        view.backgroundColor = R.color.mainBlack()!
        prepareFABButton()
        prepareWebsiteButton()
        preparePlaceButton()
        prepareFABMenu()
        //fabMenuBacking = .blur
    }
}

extension RightFabMenuView {
    fileprivate func prepareFABButton() {
        fabButton = FABButton(image: Icon.icon("ic_add_white"), tintColor: R.color.mainWhite()!)
        fabButton.backgroundColor = R.color.subNavy()!
        fabButton.pulseColor = R.color.mainWhite()!
    }

    fileprivate func prepareWebsiteButton() {
        urlFABMenuItem = FABMenuItem()
        urlFABMenuItem.title = "Add website".localized
        s.prepareFabMenuItemColors(item: urlFABMenuItem, icon: Icon.icon("ic_add_white"), backgroundColor: R.color.subRed()!)
        urlFABMenuItem.fabButton.addTarget(self, action: #selector(handleWebsiteFABMenuItem(button:)), for: .touchUpInside)
    }

    fileprivate func preparePlaceButton() {
         placeFABMenuItem = FABMenuItem()
        placeFABMenuItem.title = "Add candidate".localized
        s.prepareFabMenuItemColors(item: placeFABMenuItem, icon: Icon.icon("ic_add_white"), backgroundColor: R.color.subRed()!)
         placeFABMenuItem.fabButton.addTarget(self, action: #selector(handlePlaceFABMenuItem(button:)), for: .touchUpInside)
     }

    fileprivate func prepareFABMenu() {
        fabMenu.fabButton = fabButton
        fabMenu.fabMenuItems = [urlFABMenuItem,placeFABMenuItem]
        view.addSubview(fabMenu)
        fabMenu.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(56)
            make.right.bottom.equalToSuperview().offset(-16)
        })
    }
}

extension RightFabMenuView {
    @objc fileprivate func handleWebsiteFABMenuItem(button: UIButton) {
        print(self.children[0])
        if let mainView = self.children[0] as? RightCollectionView{
            Segues().websiteSegue(in: 0, state: .newURL, controller: mainView)
        }
        fabMenu.close()
        fabMenu.fabButton?.animate(.rotate(0))
    }
    @objc fileprivate func handlePlaceFABMenuItem(button: UIButton) {
        if let mainView = self.children[0] as? RightCollectionView{
            RealmOthers().savePlace() //ここで追加したから 下のは-1に変更
            mainView.placeLocationSegue(in: RealmOthers().place().count-1, state: .new)
        }
        fabMenu.close()
        fabMenu.fabButton?.animate(.rotate(0))
    }
}

extension RightFabMenuView {
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
