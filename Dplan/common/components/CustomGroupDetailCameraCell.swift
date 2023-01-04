//
//  CustomGroupDetailCameraCell.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/27.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import DKImagePickerController

class CustomGroupDetailCameraCell: DKAssetGroupDetailBaseCell {
    
    class override func cellReuseIdentifier() -> String {
        return "CustomGroupDetailCameraCell"
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageFrame = CGRect(x: frame.width/3,
                                y: frame.width/3,
                                width: frame.width/3,
                                height: frame.height/3)
        let cameraImage = UIImageView(frame: imageFrame)
        cameraImage.image = UIImage(systemName: "camera")
        cameraImage.tintColor = R.color.mainBlack()!
        contentView.addSubview(cameraImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

