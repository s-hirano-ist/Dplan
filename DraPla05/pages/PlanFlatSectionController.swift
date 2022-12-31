//
//  PlanFlatSectionController.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/31.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import UIKit
import IGListKit
import SwipeCellKit
protocol PlanFlatSectionDelegate {
    func planPressed(at row:Int)->Void
    func planShareButtonPressed(at row:Int)->Void
    func planFavoriteButtonPressed(at row:Int)->Void
    func planReload()->Void
}
class PlanFlatSectionController: ListSectionController {
    private var plan: Plan?
    var delegate:PlanFlatSectionDelegate?
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width,
                      height: 80)
    }
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cellType = plan!.image==nil ? FlatNonImageCell.self : FlatCell.self
        let cell = collectionContext!.dequeueReusableCell(of: cellType,
                                                          for: self,
                                                          at: index)
        if let cell = cell as? FlatCell {
            if let planData = plan {
                cell.setData(withName: planData.title,
                             detail: Settings().convertedTime(planData: planData),
                             titleImage: planData.image,
                             isFav: planData.isFavorite)
                cell.flatCellDelegate = self
                cell.delegate = self
            }else{
                ERROR("DATA CELL SET NOT SELECTED NIL AT PLACENUMBER")
            }
        }else if let cell = cell as? FlatNonImageCell{
            if let planData = plan {
                cell.setData(withName: planData.title,
                             detail: Settings().convertedTime(planData: planData),
                             isFav: planData.isFavorite)
                cell.flatCellDelegate = self
                cell.delegate = self
            }else{
                ERROR("DATA CELL SET NOT SELECTED NIL AT PLACENUMBER")
            }
        }
        return cell
    }
    override func didUpdate(to object: Any) {
        plan = object as? Plan
    }
    override func didSelectItem(at index: Int) {
        let number = section - 1
        self.delegate?.planPressed(at: number)
    }
}
extension PlanFlatSectionController:FlatCellDelegate,FlatNonImageCellDelegate {
    func nonImageFavoriteButtonPressed() {
        let number = section - 1
        self.delegate?.planFavoriteButtonPressed(at: number)
    }
    func nonImageShareButtonPressed() {
        let number = section - 1
        self.delegate?.planShareButtonPressed(at: number)
    }
    func favoriteButtonPressed() {
        let number = section - 1
        self.delegate?.planFavoriteButtonPressed(at: number)
    }
    func shareButtonPressed() {
        let number = section - 1
        self.delegate?.planShareButtonPressed(at: number)
    }
}
extension PlanFlatSectionController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right {
            let deleteAction = SwipeAction(style: .default, title: "Delete".localized) {
                action, indexPath in
                let number = indexPath.section - 1
                RealmPlan().deletePlan(at: number)
                self.delegate?.planReload()
            }
            deleteAction.image = UIImage(systemName: "xmark")
            deleteAction.backgroundColor = R.color.subRed()!
            deleteAction.hidesWhenSelected = true
            return [deleteAction]
        }else{
            let number = indexPath.section - 1
            let addPinAction = SwipeAction(style: .default, title: "Add pin".localized) {
                action, indexPath in
                RealmPlan().setIsFavorite(at: number, to: !RealmPlan().getisFavorite(at: number))
                self.delegate?.planReload()
            }
            if RealmPlan().getisFavorite(at: number) == true {
                addPinAction.title = "Delete pin".localized
            }
            addPinAction.image = UIImage(systemName: "mappin.circle")
            addPinAction.backgroundColor = R.color.subBlue()!
            addPinAction.hidesWhenSelected = true
            return [addPinAction]
        }
    }
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .none
        options.transitionStyle = .border
        return options
    }
}
