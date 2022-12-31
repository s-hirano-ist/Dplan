//
//  ImagePickerController.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/10.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import Foundation
import Eureka

/// Selector Controller used to pick an image
open class ImagePickerController : UIImagePickerController, TypedRowControllerType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /// The row that pushed or presented this controller
    public var row: RowOf<UIImage>!

    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?

    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        (row as? ImageRow)?.imageURL = info[.referenceURL] as? URL //下記rename
        //(row as? ImageRow)?.imageURL = info[.UIImagePickerController.InfoKey.phAsset] as? URL

        row.value = info[.originalImage] as? UIImage
        onDismissCallback?(self)
    }

    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        onDismissCallback?(self)
    }
}
