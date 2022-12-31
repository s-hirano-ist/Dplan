//
//  ImageCell.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/29.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import UIKit
import SnapKit

class ImageCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .blue
        view.contentMode = .scaleAspectFill
        //view.contentMode = .scaleAspectFit
        //view.contentMode = .redraw

        view.clipsToBounds = true
        //view.translatesAutoresizingMaskIntoConstraints = true
        //view.sizeToFit()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return view
    }()

    let activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.startAnimating()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(activityView)

        contentView.snp.makeConstraints({ (make) -> Void in
            make.top.right.left.bottom.top.equalToSuperview()
        })
        imageView.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.top.equalTo(contentView)
            make.height.equalTo(contentView.snp.width)
        })
        activityView.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.top.equalTo(contentView)
            make.height.equalTo(contentView.snp.width)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(image: UIImage?) {
        imageView.image = image
        if image != nil {
            activityView.stopAnimating()
        } else {
            activityView.startAnimating()
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
//        print(newFrame)
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}

