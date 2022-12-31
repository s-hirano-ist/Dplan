//
//  HeaderSectionController.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/30.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import UIKit
import IGListKit
protocol HeaderSectionDelegate {
    func showAllButtonClicked(at row:Int)->Void
    func showMapButtonClicked(at row:Int)->Void
}

class HeaderSectionController: ListSectionController {
    private var sectionNumber:Int?
    var delegate: HeaderSectionDelegate?

    override func sizeForItem(at index: Int) -> CGSize {
        if index == 0 {
            return CGSize(width: collectionContext!.containerSize.width,
                          height: 44)
        }else{
            return CGSize(width: collectionContext!.containerSize.width,
            height: 100)
        }
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cellType = index == 0 ? HeaderCell.self : EmptyCell.self
        let cell = collectionContext!.dequeueReusableCell(of: cellType,
                                                          for: self,
                                                          at: index)
        if let cell = cell as? HeaderCell,let sectionNumber = sectionNumber {
            switch sectionNumber {
            case 0:
                cell.setLabel(title: "Websites".localized, mapHidden: true)
            case 1:
                cell.setLabel(title: "Candidate places".localized, mapHidden: false)
            case 2:
                cell.setLabel(title: "Notes".localized, mapHidden: true)
            case 3:
                cell.setLabel(title: "Images".localized, mapHidden: true)
            case 4:
                cell.setLabel(title: "Plans".localized, mapHidden: false)
            case 5:
                cell.setLabel(title: "Plans".localized, mapHidden: false)
            case 6:
                cell.setLabel(title: "Websites".localized, mapHidden: true)
            case 7:
                cell.setLabel(title: "Candidate places".localized, mapHidden: false)
            case 8:
                cell.setLabel(title: "Images".localized, mapHidden: true)
            default:
                ERROR("ERROR HEADERCELL")
            }
            cell.delegate = self
        }else if let cell = cell as? EmptyCell {
            switch sectionNumber {
            case 5:
                cell.setText(text: "Tap the \" + \" button to add a new plan".localized)
            case 6:
                cell.setText(text: "Tap the \" + \" button to add a new bookmark to a website".localized)
            case 7:
                cell.setText(text: "Tap the \" + \" button to add a new place you want to go".localized)
            case 8:
                cell.setText(text: "Add images to plans on the left screen or place you want to go to show images here".localized)
            default:
                ERROR("ERROR IN EMPTY CELL")
            }
        }
        return cell
    }

    override func didUpdate(to object: Any) {
        sectionNumber = object as? Int
    }
    override func numberOfItems() -> Int {
        if let number = sectionNumber {
            if number <= 4 {
                return 1
            }else{
                return 2
            }
        }else{
            ERROR("ERROR IN NUMBER OF ITEMS")
            return 0
        }
    }
}

extension HeaderSectionController: HeaderCellDelegate {
    func showAllButtonClicked() {
        self.delegate?.showAllButtonClicked(at:sectionNumber!)
    }
    func showMapButtonClicked() {
        self.delegate?.showMapButtonClicked(at:sectionNumber!)
    }
}
