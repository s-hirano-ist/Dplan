//
//  MainHeaderSectionController.swift
//  Dplan
//
//  Created by S.Hirano on 2020/04/01.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import SwipeCellKit
protocol MainHeaderSectionDelegate {
    func timeClicked(at section:Int,_ row:Int)->Void
    func timePickerActivate(at section:Int,_ row:Int)->Void
}

class MainHeaderSectionController: ListSectionController {
    var delegate: MainHeaderSectionDelegate?
    var data: Int?
    override func sizeForItem(at index: Int) -> CGSize {
        if data == 0 {
            return CGSize(width: collectionContext!.containerSize.width,height: 20)
        }else{
            if index == 0{
                return CGSize(width: collectionContext!.containerSize.width,height: 50)
            }else{
                return CGSize(width: collectionContext!.containerSize.width,height: 20)
            }
        }
    }
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cellType:UICollectionViewCell.Type
        if data == 0 {
            cellType = HeaderCollectionCell.self
        }else {
            cellType = index != 0 ? HeaderCollectionCell.self : TimeCollectionCell.self
        }
        let cell = collectionContext!.dequeueReusableCell(of: cellType, for: self, at: index)
        if let cell = cell as? TimeCollectionCell{
            cell.setCell(with: RealmPlan().data(at: data!, 0))
            cell.delegate = self
        }
        return cell
    }
    override func didUpdate(to object: Any) {
        data = object as? Int
    }
    override func didSelectItem(at index: Int) {
        if data != 0{
            if index == 0 {
                self.delegate?.timeClicked(at: data ?? 0,0)
            }
        }
    }
    override func numberOfItems() -> Int {
        if data == 0 {
            return 1
        }else{
            return 2
        }
    }
}

extension MainHeaderSectionController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right { return [] }
        if indexPath.row == 0 && data != 0 { //time Cell
            let sections = (data ?? 1)
            let rows = 0
            let editTimeTakenAction = SwipeAction(style: .default, title: "Edit taken time".localized) {
                action, indexPath in
                self.delegate?.timePickerActivate(at: sections, rows)
            }
            let showRouteAction = SwipeAction(style: .default, title: "Show route".localized) {
                action, indexPath in
                print("\(sections),\(rows)")
                let currentLoc = RealmPlan().data(at: sections-1,
                                                  RealmPlan().countDestination(at: NUMBER, in: sections-1)-1).location
                let destLoc = RealmPlan().data(at: sections, rows).location
                let transport = RealmPlan().data(at: sections, rows).transport
                Segues().openGoogleMaps(withCurrentLoc: currentLoc, destinationLoc: destLoc, transport: transport)
            }
            editTimeTakenAction.hidesWhenSelected = true
            showRouteAction.hidesWhenSelected = true
            showRouteAction.backgroundColor = R.color.subBlue()!
            editTimeTakenAction.backgroundColor = R.color.subNavy()!
            showRouteAction.image = UIImage(systemName: "map.fill")
            editTimeTakenAction.image = UIImage(systemName: "pencil")
            return [showRouteAction,editTimeTakenAction]
        }
        return []
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .none
        options.transitionStyle = .border
        return options
    }
}
