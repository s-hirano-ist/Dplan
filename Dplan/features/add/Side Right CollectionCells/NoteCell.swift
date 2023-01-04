//
//  NoteCell.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/29.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit

protocol NoteCellDelegate {
    func saveText(text:String)->Void
}

class NoteCell: UICollectionViewCell {
    var delegate:NoteCellDelegate?

    lazy var textView:UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.textColor = R.color.mainBlack()!
        textView.backgroundColor = R.color.mainWhite()!
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textView)
        contentView.snp.makeConstraints({ (make) -> Void in
            make.top.right.left.bottom.top.equalToSuperview()
        })
        textView.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
            make.bottom.top.equalTo(contentView)
            //make.height.greaterThanOrEqualTo(100)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setText(text:String) {
        if text == String.empty{
            textView.text = String.empty
        }else{
            textView.text = text
        }
    }
}

extension NoteCell:UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.saveText(text: textView.text)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.isScrollEnabled = true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.isScrollEnabled = false
        return true
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
