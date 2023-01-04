//
//  TopBarView.swift
//  Dplan
//
//  Created by Soraki Hirano on 2023/01/04.
//  Copyright © 2023 Sola Studio. All rights reserved.
//

import UIKit
import Material

protocol TopBarViewDelegate {
    func addNewPlan() -> Void
    func showSettings() -> Void
}

class TopBarView: UIView {
    let s = Settings()
    
    var delegate: TopBarViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.addSubview(titleLabel)
        self.addSubview(showSettingsButton)
        self.addSubview(addNewPlanButton)
        self.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(44)
        })
        titleLabel.snp.makeConstraints({(make) -> Void in
            make.top.equalToSuperview()
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(16)
        })
        showSettingsButton.snp.makeConstraints({ (make) -> Void in
            make.top.equalToSuperview()
            make.size.equalTo(44)
            make.right.equalToSuperview().offset(-16)
        })
        addNewPlanButton.snp.makeConstraints({ (make) -> Void in
            make.top.equalToSuperview()
            make.size.equalTo(44)
            make.right.equalTo(showSettingsButton.snp.left)
        })
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.text = "Dplan by Sola Studio"
        label.font = UIFont(name: "MarkerFelt-Thin", size: 15)
        //TODO: change to better fonts
        label.textAlignment = .left
        label.isUserInteractionEnabled = true
        //        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTitleLabelClick(gestureRecognizer:))))
        return label
    }()
    /* TODO: add files from jsons
     @objc func handleTitleLabelClick(gestureRecognizer:UIGestureRecognizer){
     Segues().setPlanDataJson(data: getPlanJson())
     adapter.performUpdates(animated: true, completion: nil)
     }
     func getPlanJson()->JsonPlanData{
     let fileName = "write.json"
     var dir = FileManager.default.urls( for: .documentDirectory,
     in: .userDomainMask).first!
     dir.appendPathComponent(fileName)
     let data = try! JSONDecoder().decode(JsonPlanData.self,
     from: try! Data(contentsOf: dir))
     return data
     }
     */
    lazy var addNewPlanButton: RaisedButton = {
        let button = s.raisedButton()
        button.tintColor = R.color.mainBlack()!
        button.image = Icon.icon("ic_add_white")
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddNewPlan(gestureRecognizer:))))
        return button
    }()
    @objc fileprivate func handleAddNewPlan(gestureRecognizer:UIGestureRecognizer) {
        self.delegate?.addNewPlan()
    }
    
    lazy var showSettingsButton: RaisedButton = {
        let button = s.raisedButton()
        button.setImage(UIImage(systemName: "gear"), for: .normal)
        button.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(handleShowSettings(gestureRecognizer:))))
        return button
    }()
    @objc fileprivate func handleShowSettings(gestureRecognizer:UIGestureRecognizer) {
        self.delegate?.showSettings()
    }
}
