//
//  TimePickerModalView.swift
//  Dplan
//
//  Created by S.Hirano on 2020/01/06.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import Material

protocol TimePickerDelegate {
    func closeTimePicker() -> Void
}

class TimePickerView: UIViewController {
    let s = Settings()

    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = R.color.mainGray()!
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.text = "Time to destination".localized
        return label
    }()
    lazy var lockLabel: UILabel = {
        let label = UILabel()
        label.text = "lock time".localized
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = R.color.mainGray()!
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    lazy var lockEnabledSwitch: UISwitch = {
        let lockEnabledSwitch = UISwitch()
        lockEnabledSwitch.addTarget(self,
                                    action: #selector(self.disableDatePicker(_ :)),
                                    for: UIControl.Event.valueChanged)
        return lockEnabledSwitch
    }()
    lazy var datePicker:UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .clear
        datePicker.setValue(R.color.mainBlack()! , forKey: "textColor")
        /*datePicker.minimumDate = Calendar.current.date(from:
            DateComponents(year: 0,
                           month: 0,
                           day: 0,
                           hour: 0,
                           minute: 0,
                           second: 0))!*/
        datePicker.minuteInterval = 10
        datePicker.datePickerMode = .countDownTimer

        return datePicker
    }()
    lazy var transportLabel:UILabel = {
        let label = UILabel()
        label.text = "Transport to here".localized
        label.textColor = R.color.mainGray()!//
        return label
    }()
    lazy var transportSelector:UISegmentedControl = {
        let items:[UIImage] = [.carImage,.trainImage,.walkImage]
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.backgroundColor = R.color.mainLightGray()!
        segmentControl.selectedSegmentTintColor = R.color.mainWhite()!
        return segmentControl
    }()
    lazy var v: UIView = {
        let view = s.setButtonBackground()
        return view
    }()
    lazy var saveButton: FlatButton = {
        let button = s.flatButton(title: "OverWrite".localized,
                                  titleColor: R.color.subBlue()!)
        button.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.saveClicked(gestureRecognizer:))))
        return button
    }()
    lazy var cancelButton: FlatButton = {
        let button = s.flatButton(title: "Cancel".localized,
                                  titleColor: R.color.mainGray()!)
        button.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.cancelClicked(gestureRecognizer:))))
        return button
    }()

    var rows = Int()
    var sections = Int()
    private let d = RealmPlan()
    var delegate: TimePickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setConstraints()
    }
    func setDatePicker() {
        if d.data(at: sections, rows).timeTo == 0.0{
            datePicker.countDownDuration = 23*60*60+50*60
        }else{
            datePicker.countDownDuration = d.data(at: sections, rows).timeTo
            DEBUG(String(datePicker.countDownDuration))
        }
        datePicker.isEnabled = d.data(at:sections,rows).isLocked
        lockEnabledSwitch.isOn = d.data(at:sections,rows).isLocked
        transportSelector.selectedSegmentIndex = d.data(at:sections,rows).transport
    }
    @objc func disableDatePicker(_ sender:UISwitch){
        datePicker.isEnabled = lockEnabledSwitch.isOn
    }
    @objc func cancelClicked(gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.closeTimePicker()
    }
    @objc func saveClicked(gestureRecognizer: UITapGestureRecognizer) {
        RealmPlan().setTimeToWithIsLocked(at: sections, rows,
                                          withTime: datePicker.countDownDuration,
                                          isLocked: lockEnabledSwitch.isOn,
                                          transport: transportSelector.selectedSegmentIndex)
        self.delegate?.closeTimePicker()
    }

    let offset:CGFloat = 16
    let buttonHeight:CGFloat = 51
    let defaultHeight: CGFloat = 31 //当ビューの高さの基準値
    let defaultSwitchWidth: CGFloat = 49

    private func setConstraints(){
        view.addSubview(transportLabel)
        view.addSubview(transportSelector)

        view.addSubview(titleLabel)
        view.addSubview(lockLabel)
        view.addSubview(lockEnabledSwitch)
        view.addSubview(datePicker)

        v.addSubview(cancelButton)
        v.addSubview(saveButton)

        view.addSubview(v)

        transportLabel.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview().offset(offset)
            make.top.equalToSuperview().offset(offset)
            make.right.equalTo(self.view.snp.centerX).offset(-offset)
            make.height.equalTo(defaultHeight)
        })
        transportSelector.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(transportLabel.snp.right)
            make.top.equalToSuperview().offset(offset)
            make.right.equalToSuperview().offset(-offset)
            make.height.equalTo(defaultHeight)
        })
        titleLabel.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview().offset(offset)
            make.top.equalTo(transportLabel.snp.bottom).offset(offset)
            make.right.equalTo(view.snp.centerX)
            make.height.equalTo(defaultHeight)
        })
        lockLabel.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(view.snp.centerX)
            make.top.equalTo(transportLabel.snp.bottom).offset(offset)
            make.right.equalTo(lockEnabledSwitch.snp.left)
            make.height.equalTo(defaultHeight)
        })
        lockEnabledSwitch.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(transportLabel.snp.bottom).offset(offset)
            make.right.equalToSuperview().offset(-offset)
            make.width.equalTo(defaultSwitchWidth)
            make.height.equalTo(defaultHeight)
        })

        datePicker.snp.makeConstraints({ (make) -> Void in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(180)
        })

        v.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(datePicker.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        })
        saveButton.snp.makeConstraints({ (make) -> Void in
            make.right.equalToSuperview()
            make.left.equalTo(view.snp.centerX)
            make.top.equalToSuperview()
            make.height.equalTo(buttonHeight)
        })
        cancelButton.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalTo(view.snp.centerX)
            make.top.equalToSuperview()
            make.height.equalTo(buttonHeight)
        })
    }
}
