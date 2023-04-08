//
//  CandidateSectionController.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/31.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import SwipeCellKit
protocol CandidateWebsiteSectionDelegate {
    func websiteClicked(at row:Int)->Void
    func webCellReload()->Void
}

class CandidateWebsiteSectionController: ListSectionController {
    private var websiteData:URLData?
    var delegate:CandidateWebsiteSectionDelegate?

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width,
                      height: 80)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: WebsiteCell.self, for: self, at: index)
        if let cell = cell as? WebsiteCell {
            if let websiteData = websiteData {
                cell.setWebsite(title: websiteData.title,
                                url: websiteData.website,
                                image: nil)
                cell.delegate = self
            }else{
                ERROR("nil error in website")
            }
        }
        return cell
    }
    override func didUpdate(to object: Any) {
        websiteData = object as? URLData
    }
    override func didSelectItem(at index: Int) {
        let number = section - RealmPlan().countPlans() - 2
        self.delegate?.websiteClicked(at: number)
    }
}

extension CandidateWebsiteSectionController: SwipeCollectionViewCellDelegate{
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .default, title: "Delete") { action, indexPath in
            let number = indexPath.section - RealmPlan().countPlans() - 2
            RealmCandidate().deleteWebsite(at: number)
            self.delegate?.webCellReload()
        }
        deleteAction.image = UIImage(named: "xmark")
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
