//
//  ImageSectionController.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/29.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
protocol ImageSectionDelegate {
    func imageClicked(at row:Int,imageData:[UIImage?])->Void
}
class ImageSectionController: ListSectionController {
    var delegate: ImageSectionDelegate?
    var imageStringList: Images?
    var imageDataArray:[UIImage?] = []

    override init() {
        super.init()
        minimumLineSpacing = 2
        minimumInteritemSpacing = 2
        workingRangeDelegate = self
    }
    override func sizeForItem(at index: Int) -> CGSize {
        let width: CGFloat = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width/2 - 2, height: width/2 - 2)
    }
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: ImageCell.self ,
                                                          for: self,
                                                          at: index)
        if let cell = cell as? ImageCell {
                cell.setImage(image: self.imageDataArray[index])
        }
        return cell
    }

    override func didUpdate(to object: Any) {
        self.imageStringList = object as? Images
        imageStringList!.imageArray.forEach{_ in
            imageDataArray.append(nil)
        }
    }
    override func numberOfItems() -> Int {
        return imageStringList?.imageArray.count ?? 0
    }

    override func didSelectItem(at index: Int) {
        self.delegate?.imageClicked(at: index,imageData: imageDataArray)
    }
}

extension ImageSectionController: ListWorkingRangeDelegate{
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerWillEnterWorkingRange sectionController: ListSectionController) {
        //MARK: もともとの動作する形
        for (index,image) in imageStringList!.imageArray.enumerated() {
            guard imageDataArray[index] == nil else { return }
            DispatchQueue.main.async {
                self.imageDataArray[index] = image?.image
                if let cell = self.collectionContext?.cellForItem(at: index, sectionController: self) as? ImageCell {
                    cell.setImage(image: image?.image)
                }
            }
        }
        //MARK: 作成中
        /*for index in 0..<(imageStringList?.imageArray.count ?? 0){
            if imageStringList[index] == nil {

            }
        }*/



    }
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerDidExitWorkingRange sectionController: ListSectionController) { }
    private func updateImage(){
        for (index,image) in imageStringList!.imageArray.enumerated() {
            guard imageDataArray[index] == nil else { return } //
            DispatchQueue.main.async {
                self.imageDataArray[index] = image?.image
                if let cell = self.collectionContext?.cellForItem(at: index, sectionController: self) as? ImageCell {
                    cell.setImage(image: image?.image)
                }
            }
        }

    }
}
