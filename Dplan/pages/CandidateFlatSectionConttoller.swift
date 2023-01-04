//
//  CandidateFlatSectionConttoller.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/31.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import SwipeCellKit
protocol CandidateFlatSectionDelegate {
    func candidatePressed(at row:Int)->Void
    func candidateShareButtonPressed(at row:Int)->Void
    func candidateFavoriteButtonPressed(at row:Int)->Void
    func candidateReload()->Void
}
class CandidateFlatSectionController: ListSectionController {
    private var placeData: PlaceData?
    var delegate:CandidateFlatSectionDelegate?

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width,
                      height: 80)
    }
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cellType = placeData!.images.first == nil ? FlatNonImageCell.self : FlatCell.self

        let cell = collectionContext!.dequeueReusableCell(of: cellType,
                                                          for: self,
                                                          at: index)
        if let cell = cell as? FlatCell {
            if let placeData = placeData {
                cell.setData(withName: placeData.name,
                             detail: placeData.detail,
                             titleImage: placeData.images.first ?? nil,
                             isFav: placeData.isFavorite)
                cell.flatCellDelegate = self
                cell.delegate = self

            }else{
                ERROR("DATA CELL SET NOT SELECTED NIL AT PLACENUMBER")
            }
        }else if let cell = cell as? FlatNonImageCell {
            if let placeData = placeData {
                cell.setData(withName: placeData.name,
                             detail: placeData.detail,
                             isFav: placeData.isFavorite)
                cell.flatCellDelegate = self
                cell.delegate = self
            }else{
                ERROR("DATA CELL SET NOT SELECTED NIL AT PLACENUMBER")
            }
        }
        return cell
    }
    override func didUpdate(to object: Any) {
        placeData = object as? PlaceData
    }
    override func didSelectItem(at index: Int) {
        let number = section - 3 - RealmPlan().countPlans() - RealmCandidate().countWebsite()
        self.delegate?.candidatePressed(at: number)
    }
}
extension CandidateFlatSectionController:FlatCellDelegate,FlatNonImageCellDelegate {
    func nonImageFavoriteButtonPressed() {
        let number = section - 3 - RealmPlan().countPlans() - RealmCandidate().countWebsite()
        self.delegate?.candidateFavoriteButtonPressed(at: number)
    }
    func nonImageShareButtonPressed() {
        let number = section - 3 - RealmPlan().countPlans() - RealmCandidate().countWebsite()
        self.delegate?.candidateShareButtonPressed(at: number)
    }
    func favoriteButtonPressed() {
        let number = section - 3 - RealmPlan().countPlans() - RealmCandidate().countWebsite()
        self.delegate?.candidateFavoriteButtonPressed(at: number)
    }
    func shareButtonPressed() {
        let number = section - 3 - RealmPlan().countPlans() - RealmCandidate().countWebsite()
        self.delegate?.candidateShareButtonPressed(at: number)
    }
}
extension CandidateFlatSectionController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right {
            let deleteAction = SwipeAction(style: .default, title: "Delete") { action, indexPath in
                let number = indexPath.section - 3 - RealmPlan().countPlans() - RealmCandidate().countWebsite()
                RealmCandidate().deleteCandidate(at: number)
                self.delegate?.candidateReload()
            }
            deleteAction.image = UIImage(systemName: "xmark")
            deleteAction.backgroundColor = R.color.subRed()!
            deleteAction.hidesWhenSelected = true
            return [deleteAction]
        }else{
            let number = indexPath.section - 3 - RealmPlan().countPlans() - RealmCandidate().countWebsite()
            let addPinAction = SwipeAction(style: .default, title: "Add pin".localized) {
                action, indexPath in
                RealmCandidate().setIsFavorite(at: number, isFav: !RealmCandidate().data(at: number).isFavorite)
                self.delegate?.candidateReload()
            }
            if RealmCandidate().data(at: number).isFavorite == true {
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
