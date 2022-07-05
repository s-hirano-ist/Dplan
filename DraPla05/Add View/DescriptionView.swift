//
//  DescriptionView.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/17.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import UIKit
import Material
protocol DescriptionViewDelegate {
    func showTimePickerClicked()->Void
}
/* size of Detail VIew

 */


class DetailView: UIView {
    private let s = Settings()
    var delegate: DescriptionViewDelegate?

    var date:Date = Date()
    var duration:Double = 0


    var addressField: UITextField!
    var timeLabel: UILabel!
    var actuallTime: UILabel!
    var timeSelectButton:FlatButton!
    var transportLabel:UILabel!
    var transportSelector: UISegmentedControl!
    var URLField: UITextField!

    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    func calculateSelfHeight(){
        let sideSpace:CGFloat = 8
        let edgeSpace:CGFloat = 8
        let space:CGFloat = 4
        let height = (frame.height - edgeSpace*2 - space*3)/4
        let width = frame.width - sideSpace*2

        addressField = UITextField(frame: CGRect(x: sideSpace,
                                                 y: edgeSpace,
                                                 width: width,
                                                 height: height))
        addressField.textColor = R.color.mainWhite()!
        addressField.placeholder = "Address".localized
        timeLabel = UILabel(frame: CGRect(x: sideSpace,
                                          y: addressField.frame.maxY,
                                          width: width/2,
                                          height: height))
        timeLabel.textColor = R.color.mainWhite()!
        actuallTime = UILabel(frame: CGRect(x: sideSpace + width/2,
                                            y: addressField.frame.maxY,
                                            width: width/2,
                                            height: height))
        actuallTime.textAlignment = .right
        actuallTime.text = "Transport to here".localized
        actuallTime.textColor = R.color.mainWhite()!

        timeSelectButton = FlatButton(frame: CGRect(x: 0,
                                                  y: addressField.frame.maxY,
                                                  width: frame.width,
                                                  height: height))
        timeSelectButton.backgroundColor = .clear
        timeSelectButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(activateTimeSelector(gestureRecognizer:))))

        transportLabel = UILabel(frame: CGRect(x: sideSpace,
                                               y: timeLabel.frame.maxY,
                                               width: width/2,
                                               height: height))
        transportLabel.textColor = R.color.mainWhite()!

        transportSelector = UISegmentedControl(frame: CGRect(x: sideSpace + width/2,
                                                             y: timeLabel.frame.maxY,
                                                             width: width/2,
                                                             height: height))
        transportSelector.insertSegment(with: .carImage, at: 0, animated: false)
        transportSelector.insertSegment(with: .trainImage, at: 1, animated: false)
        transportSelector.insertSegment(with: .walkImage, at: 2, animated: false)
        transportSelector.backgroundColor = R.color.mainLightGray()!
        transportSelector.selectedSegmentTintColor = R.color.mainWhite()!


        transportSelector.addTarget(self, action: #selector(segmentChanged(_ :)), for: .valueChanged)

        URLField = UITextField(frame: CGRect(x: sideSpace,
                                             y: transportSelector.frame.maxY,
                                             width: width,
                                             height: height))
        URLField.textColor = R.color.mainWhite()!

        addSubview(addressField)
        addSubview(timeLabel)
        addSubview(actuallTime)
        addSubview(timeSelectButton)
        addSubview(transportLabel)
        addSubview(transportSelector)
        addSubview(URLField)
    }
    @objc func segmentChanged(_: AnyObject) {
        //セグメントが変更されたときの処理
        //選択されているセグメントのインデックス
        let selectedIndex = transportSelector.selectedSegmentIndex
        print(selectedIndex)
    }
    @objc func activateTimeSelector(gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.showTimePickerClicked()
    }
    func loadNib(){
        let view = Bundle.main.loadNibNamed("DescriptionView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        calculateSelfHeight()
        addressField.inputAccessoryView = doneButtonToolBar()
        URLField.inputAccessoryView = doneButtonToolBar()
    }

    func reloadDateDuration(state:EditState,isEnabled:Bool){
        switch state {
        case .newPlan,.editPlan,.showPlan:
            timeLabel.text = "Departing date".localized
            actuallTime.text = s.dateFormatter().string(from: date)
        case .newDest,.editDest,.showDest:
            timeLabel.text = "Stay time".localized
            actuallTime.text = s.durationFormatter(time: duration)
        case .newDayDest,.editDayDest,.showDayDest:
            timeLabel.text = "Departing time".localized
            actuallTime.text = s.timeFormatter().string(from: date)
        case .newURL,.editURL,.newURLCandidate,.editURLCandidate:
            ERROR("SELECTION STATE")
        case .newOthers,.editOthers,.showOthers,.newCandidate,.editCandidate,.showCandidate:
            ERROR("NO NEED")
        }
        setIsEnabled(isEnabled: isEnabled)
    }

    private func setIsEnabled(isEnabled:Bool){
        addressField.isEnabled = isEnabled
        actuallTime.isEnabled = isEnabled
        transportSelector.isUserInteractionEnabled = isEnabled
        URLField.isEnabled = isEnabled
        timeSelectButton.isEnabled = isEnabled
    }
    func setPlan(data:EachData,state:EditState,isEnabled:Bool){
        transportLabel.text = "Transport to here".localized
        addressField.text = data.address
        if data.URL == String.empty{
            URLField.placeholder = "URL".localized
            URLField.text = nil
            URLField.attributedPlaceholder = NSAttributedString(
                string:"URL".localized,
                attributes: [NSAttributedString.Key.foregroundColor : R.color.mainLightGray()!])
        }else{
            URLField.text = data.URL
        }
        switch data.transport {
        case 0:transportSelector.selectedSegmentIndex = 0
        case 1:transportSelector.selectedSegmentIndex = 1
        case 2:transportSelector.selectedSegmentIndex = 2
        default: ERROR("TRANSPORT SELECTION")
        }
        switch state {
        case .newDest,.editDest,.showDest:
            date = Calendar.current.date(from: DateComponents(hour: 8,minute: 00))!
            duration = data.timeIn
        case .newDayDest,.editDayDest,.showDayDest:
            date = data.time
            duration = 0.0
        case .newPlan,.editPlan,.showPlan:
            date = data.time
            duration = 0.0
        case .newURL,.editURL,.newURLCandidate,.editURLCandidate:
            ERROR("SELECTION STATE")
        case .newOthers,.editOthers,.showOthers,.newCandidate,.editCandidate,.showCandidate:
            ERROR("NO NEED")
        }
        reloadDateDuration(state: state,isEnabled: isEnabled)
    }
    func setPlace(with data:PlaceData,isEnabled:Bool){
        addressField.text = data.address
        if data.URL == String.empty{
            URLField.placeholder = "URL".localized
            URLField.text = nil
            URLField.attributedPlaceholder = NSAttributedString(
                string:"URL".localized,
                attributes: [NSAttributedString.Key.foregroundColor : R.color.mainLightGray()!])
        }else{
            URLField.text = data.URL
        }
        setIsEnabled(isEnabled: isEnabled)
    }
}

extension DetailView:UITextFieldDelegate{
    private func doneButtonToolBar()->UIToolbar{
        // ツールバー生成
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        // スタイルを設定
        toolBar.barStyle = UIBarStyle.default
        // 画面幅に合わせてサイズを変更
        toolBar.sizeToFit()
        // 閉じるボタンを右に配置するためのスペース?
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                     target: self, action: nil)
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(commitButtonTapped))
        // スペース、閉じるボタンを右側に配置
        toolBar.items = [spacer, commitButton]
        return toolBar
    }
    @objc func commitButtonTapped() {
        self.endEditing(true)
    }
}
