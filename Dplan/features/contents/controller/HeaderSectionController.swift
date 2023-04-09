//
//  HeaderSectionController.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/30.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit

class HeaderSectionController: ListSectionController {
    private var sectionNumber:Int?
    
    override func sizeForItem(at index: Int) -> CGSize {
        if index == 0 {
            return CGSize(width: collectionContext!.containerSize.width,
                          height: 44)
        }else{
            return CGSize(width: collectionContext!.containerSize.width,
                          height: 100)
        }
    }
    
    //FIXME: parent viewからテキストを指定
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cellType = index == 0 ? HeaderCell.self : EmptyCell.self
        let cell = collectionContext!.dequeueReusableCell(of: cellType,
                                                          for: self,
                                                          at: index)
        if let cell = cell as? HeaderCell {
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
