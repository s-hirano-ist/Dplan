//
//  NotesSectionController.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/29.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit

class NotesSectionController: ListSectionController {
    private var planData:Plan?

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width,
                      height: 200)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: NoteCell.self, for: self, at: index)
        if let cell = cell as? NoteCell {
            if let noteData = planData {
                cell.setText(text: noteData.detail)
                cell.delegate = self
            }else{
                ERROR("NIL ERROR IN notes")
            }
        }
        return cell
    }

    override func didUpdate(to object: Any) {
        planData = object as? Plan
    }
    override init() {
        super.init()
        //inset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        //minimumLineSpacing = 4
        //minimumInteritemSpacing = 4
    }
}
extension NotesSectionController: NoteCellDelegate {
    func saveText(text: String) {
        RealmOthers().setText(note: text)
    }
}
