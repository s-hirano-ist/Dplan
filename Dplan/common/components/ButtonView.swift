//
//  ButtonView.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/17.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import Material
protocol ButtonViewDelegate {
    func buttonTapped(view:ButtonView) -> Void
}

class ButtonView: UIView {
    var delegate: ButtonViewDelegate?

    @IBOutlet weak var button: FlatButton!
    @IBOutlet weak var titleLabel: UILabel!


    override init(frame: CGRect){
           super.init(frame: frame)
           loadNib()
       }

       required init(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)!
           loadNib()
       }

       func loadNib(){
           let view = Bundle.main.loadNibNamed("ButtonView", owner: self, options: nil)?.first as! UIView
           view.frame = self.bounds
           self.addSubview(view)
       }

    func setButton(title:String){
        button.backgroundColor = .clear
        button.isEnabled = true
        button.pulseColor = R.color.mainWhite()!
        button.titleColor = R.color.mainWhite()!
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:))))
        button.isUserInteractionEnabled = true

        titleLabel.text = title
        titleLabel.numberOfLines = 0

        self.backgroundColor = .systemGray5
        self.cornerRadiusPreset = .cornerRadius3
    }
    func disable(){
        button.isEnabled = false
        button.pulseColor = .clear
        button.backgroundColor = .clear
        self.backgroundColor = .clear
        titleLabel.text = String.empty
    }

    @objc func tapped(gestureRecognizer: UITapGestureRecognizer){
        self.delegate?.buttonTapped(view: self)
    }
}
