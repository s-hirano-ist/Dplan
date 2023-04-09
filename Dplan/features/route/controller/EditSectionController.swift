//
//  EditSectionController.swift
//  Dplan
//
//  Created by S.Hirano on 2020/04/01.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import SwipeCellKit

protocol EditSectionDelegate {
    func editPlaceClicked(at section:Int,_ row:Int)->Void
    func dismissFromDelete()->Void
    func reloadFromEdit()->Void
}

class EditSectionController: ListSectionController {
    var delegate: EditSectionDelegate?
    var data: Daydata?

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width,height: 60)
    }
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: EventCollectionCell.self, for: self, at: index)
        if let cell = cell as? EventCollectionCell {
            if let data = data {
                cell.setHeaderCell(with: data.eachData[index], isEditing: false)
                cell.delegate = self
            }else{
                ERROR("NIL ERROR IN event cell")
            }
        }
        return cell
    }
    override func didUpdate(to object: Any) {
        data = object as? Daydata
    }
    override func numberOfItems() -> Int {
        return data?.eachData.count ?? 0
    }
    override func didSelectItem(at index: Int) {
        self.delegate?.editPlaceClicked(at: section, index)
    }
    override func canMoveItem(at index: Int) -> Bool {
        return true
    }
    let d = RealmPlan()

    override func moveObject(from sourceIndex: Int, to destinationIndex: Int) {
        let sourceIndexPath = d.calculateIndex(index: sourceIndex)
        let destIndexPath = d.calculateIndex(index: destinationIndex)
        d.moveTo(source: sourceIndexPath, dest: destIndexPath)
    }

}

extension EditSectionController: SwipeCollectionViewCellDelegate {

    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right { return [] }
        let deleteAction = SwipeAction(style: .default, title: "Delete".localized) {
            action, indexPath in
            if RealmPlan().countDays(at: NUMBER) == 1 && RealmPlan().countDestination(at: NUMBER, in: self.section) <= 1 {
                //1日only ∧ dest個数1つ
                RealmPlan().deletePlan(at: NUMBER)
                self.delegate?.dismissFromDelete()
            }else if RealmPlan().countDestination(at: NUMBER, in: self.section) <= 1 {
                //セクション多数 ∧ dest個数1つ
                RealmPlan().deleteSection(at: self.section)
                self.delegate?.reloadFromEdit()
            }else{
                RealmPlan().deleteRow(at: self.section, indexPath.row)
                self.delegate?.reloadFromEdit()
            }
        }
        deleteAction.image = UIImage(systemName: "xmark")
        deleteAction.backgroundColor = R.color.subRed()!
        deleteAction.hidesWhenSelected = true
        return [deleteAction]
    }

    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .none
        options.transitionStyle = .border
        return options
    }
}
