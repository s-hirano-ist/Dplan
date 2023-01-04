//
//  CustomImagePickerDelegate.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/27.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import DKImagePickerController

open class CustomImagePickerDelegate: DKImagePickerControllerBaseUIDelegate {

    override open func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController) {
        self.imagePickerController = imagePickerController
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.createDoneButtonIfNeeded())
    }
    override open func imagePickerController(_ imagePickerController: DKImagePickerController,
                                             showsCancelButtonForVC vc: UIViewController) {
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                               target: imagePickerController,
                                                               action: #selector(imagePickerController.dismiss as () -> Void))
    }

    override open func imagePickerController(_ imagePickerController: DKImagePickerController,
                                             hidesCancelButtonForVC vc: UIViewController) {
        vc.navigationItem.leftBarButtonItem = nil
    }

    override open func imagePickerControllerHeaderView(_ imagePickerController: DKImagePickerController) -> UIView? {
        return nil
    }
    override open func imagePickerControllerFooterView(_ imagePickerController: DKImagePickerController) -> UIView? {
        return nil
    }
    override open func imagePickerControllerCollectionViewBackgroundColor() -> UIColor {
        return UIColor.white
    }
    open override func imagePickerControllerCollectionImageCell() -> DKAssetGroupDetailBaseCell.Type {
        return CustomGroupDetailImageCell.self
    }
    open override func imagePickerControllerCollectionCameraCell() -> DKAssetGroupDetailBaseCell.Type {
        return CustomGroupDetailCameraCell.self
    }

    open override func imagePickerController(_ imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset]) {
        //選択検知
        //use this place for asset selection customisation
        //ERROR("didClickAsset for selection")
    }
    open override func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset]) {
        //選択解除 検知
        //use this place for asset deselection customisation
        //ERROR("didClickAsset for deselection")
    }

}
