//
//  EventSectionController.swift
//  Dplan
//
//  Created by S.Hirano on 2020/04/01.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import SwipeCellKit

protocol NonEditSectionDelegate {
    func placeClicked(at section:Int,_ row:Int)->Void
    func editPlaceClicked(at section:Int,_ row:Int)->Void
    func timeClicked(at section:Int,_ row:Int)->Void
    func timePickerActivate(at section:Int,_ row:Int)->Void
}

class NonEditSectionController: ListSectionController {
    var delegate: NonEditSectionDelegate?
    var data: Daydata?

    override func sizeForItem(at index: Int) -> CGSize {
        if index % 2 == 0{
            return CGSize(width: collectionContext!.containerSize.width,height: 50)
        }else{
            return CGSize(width: collectionContext!.containerSize.width,height: 50)
            //return CGSize(width: collectionContext!.containerSize.width,height: 40)
        }
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cellType = index%2 != 0 ? TimeCollectionCell.self : EventCollectionCell.self
        let cell = collectionContext!.dequeueReusableCell(of: cellType, for: self, at: index)
        if let cell = cell as? EventCollectionCell {
            if let data = data {
                if index == 0 {
                    cell.setHeaderCell(with: data.eachData[index/2], isEditing: false)
                    cell.delegate = self
                }else{
                    cell.setCell(with: data.eachData[index/2], isEditing: false)
                    cell.delegate = self
                }
            }else{
                ERROR("NIL ERROR IN event cell")
            }
        }else if let cell = cell as? TimeCollectionCell {
            if let data = data {
                cell.setCell(with: data.eachData[(index+1)/2])
                cell.delegate = self
            }else{
                ERROR("NIL ERROR IN Time cell")
            }
        }
        return cell
    }
    override func didUpdate(to object: Any) {
        data = object as? Daydata
    }
    override func numberOfItems() -> Int {
        if let data = data {
            return data.eachData.count * 2 - 1
        }else {
            return 0
        }
    }
    override func didSelectItem(at index: Int) {
        if index % 2 == 0 { //places
            let sections = (section-1)/2
            let rows = index/2
            self.delegate?.placeClicked(at: sections, rows)
        }else{ //routes
            let sections = (section-1)/2
            let rows = (index+1)/2
            self.delegate?.timeClicked(at: sections, rows)
        }
    }
}

extension NonEditSectionController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right { return [] }
        if indexPath.row % 2 != 0 { //Time Cell
            let sections = (section - 1)/2
            let rows = (indexPath.row+1)/2
            let editTimeTakenAction = SwipeAction(style: .default, title: "Edit taken time".localized) {
                action, indexPath in
                print("\(sections),\(rows)")
                self.delegate?.timePickerActivate(at: sections, rows)
            }
            let showRouteAction = SwipeAction(style: .default, title: "Show route".localized) {
                action, indexPath in
                print("\(sections),\(rows)")
                let currentLoc = RealmPlan().data(at: sections, rows-1).location
                let destLoc = RealmPlan().data(at: sections, rows).location
                let transport = RealmPlan().data(at: sections, rows).transport
                Segues().openGoogleMaps(withCurrentLoc: currentLoc, destinationLoc: destLoc, transport: transport)

            }
            showRouteAction.hidesWhenSelected = true
            editTimeTakenAction.hidesWhenSelected = true

            showRouteAction.image = UIImage(systemName: "map.fill")
            editTimeTakenAction.image = UIImage(systemName: "pencil")
            showRouteAction.backgroundColor = R.color.subBlue()!
            editTimeTakenAction.backgroundColor = R.color.subNavy()!
            return [editTimeTakenAction,showRouteAction]
        }else{ //Event Cell
            let sections = (section-1)/2
            let rows = indexPath.row/2
            let editDestinationAction = SwipeAction(style: .default, title: "Edit destination".localized) {
                action, indexPath in
                self.delegate?.editPlaceClicked(at: sections, rows)
            }
            let showRouteFromHereAction = SwipeAction(style: .default, title: "Show route from here".localized) {
                action, indexPath in
                let name = RealmPlan().data(at: sections, rows).name
                let transport = RealmPlan().data(at: sections, rows).transport
                Segues().openGoogleMaps(withDestinationName: name, transport: transport)
            }
            editDestinationAction.hidesWhenSelected = true
            showRouteFromHereAction.hidesWhenSelected = true
            editDestinationAction.image = UIImage(systemName: "pencil")
            showRouteFromHereAction.image = UIImage(systemName: "map.fill")
            showRouteFromHereAction.backgroundColor = R.color.subBlue()!
            editDestinationAction.backgroundColor = R.color.subNavy()!

            return [editDestinationAction,showRouteFromHereAction]
        }

    }

    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .none
        options.transitionStyle = .border
        return options
    }
}

/*longPressGesture.numberOfTapsRequired = 1//how many taps(defalut 0)
 longPressGesture.numberOfTouchesRequired = 2//(default 1)
 longPressGesture.minimumPressDuration = 0.5//(default 0.5sec)
 longPressGesture.allowableMovement = 1//(default 1px)*/
//myView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longPressHeader(gestureRecognizer:))))
