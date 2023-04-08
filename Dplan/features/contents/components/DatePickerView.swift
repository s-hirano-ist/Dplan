//
//  DatePickerView.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/21.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import Material
import SnapKit

protocol DatePickerDelegate {
    func closeDatePicker() -> Void
}

class DatePickerView: UIViewController {
    let s = Settings()
    let d = RealmPlan()
    var delegate: DatePickerDelegate?

    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = R.color.mainGray()!
        label.backgroundColor = .clear
        label.textAlignment = .left
        return label
    }()
    lazy var datePicker:UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .clear
        datePicker.setValue(R.color.mainBlack()! , forKey: "textColor")
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
        let button = s.flatButton(title: "Set".localized,
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


    var state = PlanState()
    var sections = Int()
    var rows = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setConstraints()
    }
    @objc func cancelClicked(gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.closeDatePicker()
    }
    @objc func saveClicked(gestureRecognizer: UITapGestureRecognizer) {
        switch state {
        case .newPlan:
            d.setTime(at: sections, rows, time: datePicker.date)
        case .newDay:
            d.setTime(at: sections, rows, time: datePicker.date)
            d.setTransport(at: sections, rows, transport: transportSelector.selectedSegmentIndex)
        case .newDest:
            d.setTimeIn(at: sections, rows, timeIn: datePicker.countDownDuration)
            d.setTransport(at: sections, rows, transport: transportSelector.selectedSegmentIndex)
        default:
            ERROR("STATE ERROR")
        }
        self.delegate?.closeDatePicker()
    }

    private func setConstraints(){
        view.addSubview(transportLabel)
        view.addSubview(transportSelector)

        view.addSubview(titleLabel)
        view.addSubview(datePicker)

        v.addSubview(cancelButton)
        v.addSubview(saveButton)

        view.addSubview(v)
        let defaultHeight: CGFloat = 31 //当ビューの高さの基準値
        let offset:CGFloat = 16
        let buttonHeight:CGFloat = 51

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
            make.right.equalToSuperview().offset(-offset)
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

//for sets
extension DatePickerView {
    func setDatePicker(){
        switch state {
        case .newPlan:
            titleLabel.text = "Date of departure".localized
            let date = d.data(at: sections, rows).time
            setPickder(withMode: .dateAndTime,
                       minuteInterval: 10)
            datePicker.setDate(date, animated: true)
            transportSelector.isHidden = true
            transportLabel.isHidden = true
        case .newDay:
            titleLabel.text = "Time to depart".localized
            let date = d.data(at: sections, rows).time
            setPickder(withMode: .dateAndTime,
                       minuteInterval: 10)
            datePicker.setDate(date, animated: true)
            transportSelector.isHidden = false
            transportLabel.isHidden = false
            transportSelector.selectedSegmentIndex = d.data(at: sections, rows).transport
        case .newDest:
            titleLabel.text = "Time at destination".localized
            let countDownDuration = d.data(at: sections, rows).timeIn
            setPickder(withMode: .countDownTimer,
                       minuteInterval: 10)
            datePicker.countDownDuration = countDownDuration
            transportSelector.isHidden = false
            transportLabel.isHidden = false
            transportSelector.selectedSegmentIndex = d.data(at: sections, rows).transport
        default:
            ERROR("ERROR IN STATE")
        }
    }
    private func setPickder(withMode mode:UIDatePicker.Mode,minuteInterval:Int){
        datePicker.datePickerMode = mode
        datePicker.minuteInterval = minuteInterval
    }
}

