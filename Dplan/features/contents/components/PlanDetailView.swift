//
//  PlanDetailView.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/30.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import Material
import SnapKit

protocol PlanDetailViewDelegate {
    func showTimePicker()->Void
    func setName(to data:String)->Void
    func setDetail(to data:String)->Void
    func setAddress(to data:String)->Void
    func setWebsite(to data:String)->Void
}

class PlanDetailView: UIView {
    let s = Settings()
    let d = RealmPlan()
    var delegate: PlanDetailViewDelegate?

    let sideSpace:CGFloat = 8
    let edgeSpace:CGFloat = 8
    let space:CGFloat = 4
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill //画面全体に 横方向
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    lazy var titlteHolder:UILabel = {
        let label = UILabel()
        label.fontSize = 10
        label.text = "place Name".localized
        label.textColor = R.color.mainGray()!//
        return label
    }()
    lazy var titleField: UITextField = {
        let textField = s.textField()
        textField.delegate = self
        textField.textColor = R.color.mainBlack()!
        textField.font = .boldSystemFont(ofSize: 27)
        textField.placeholder = "例) 大阪駅".localized
        return textField
    }()
    lazy var detailHolder:UILabel = {
        let label = UILabel()
        label.fontSize = 10
        label.text = "Details".localized
        label.textColor = R.color.mainGray()!//
        return label
    }()
    lazy var detailField: UITextField = {
        let textField = s.textField()
        textField.delegate = self
        textField.textColor = R.color.mainBlack()!
        textField.font = .systemFont(ofSize: 16)
        textField.placeholder = "例) 出発地".localized
        return textField
    }()
    lazy var addressHolder:UILabel = {
        let label = UILabel()
        label.fontSize = 10
        label.text = "例) 大阪府大阪市北区梅田３丁目１−１".localized
        label.textColor = R.color.mainGray()!//
        return label
    }()
    lazy var addressField:UITextField = {
        let textField = s.textField()
        textField.delegate = self
        textField.placeholder = "Address".localized
        textField.textColor = R.color.mainBlack()!//
        return textField
    }()
    lazy var websiteHolder:UILabel = {
        let label = UILabel()
        label.fontSize = 10
        label.text = "Website".localized
        label.textColor = R.color.mainGray()!//
        return label
    }()
    lazy var websiteField:UITextField = {
        let textField = s.textField()
        textField.delegate = self
        textField.textColor = R.color.mainBlack()!//
        textField.placeholder = "例) https://www.google.com/".localized //
        return textField
    }()

    lazy var timeHolder:UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill //画面全体に縦方向
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        return stackView
    }()
    lazy var timeLabel:UILabel = {
        let label = UILabel()
        label.fontSize = 10
        label.textColor = R.color.mainGray()!//
        return label
    }()
    lazy var transportLabel:UILabel = {
        let label = UILabel()
        label.fontSize = 10
        label.text = "Transport to here".localized
        label.textColor = R.color.mainGray()!//
        return label
    }()

    lazy var timeField: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill //画面全体に縦方向
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        return stackView
    }()
    lazy var actuallTime:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = R.color.mainBlack()!//
        return label
    }()
    lazy var timeSelectButton:FlatButton = {
        let button = FlatButton()
        button.backgroundColor = .clear
        button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(activateTimeSelector(_:))))
        return button
    }()
    lazy var transportImage:UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = false
        imageView.tintColor = R.color.mainBlack()!
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame:frame)
        setConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func activateTimeSelector(_: AnyObject) {
        self.delegate?.showTimePicker()
    }
}

extension PlanDetailView {
    private func setConstraints(){
        addSubview(stackView)
        stackView.addArrangedSubview(titlteHolder)
        stackView.addArrangedSubview(titleField)

        stackView.addArrangedSubview(detailHolder)
        stackView.addArrangedSubview(detailField)

        stackView.addArrangedSubview(addressHolder)
        stackView.addArrangedSubview(addressField)

        stackView.addArrangedSubview(websiteHolder)
        stackView.addArrangedSubview(websiteField)

        stackView.addArrangedSubview(timeHolder)
        stackView.addArrangedSubview(timeField)

        timeHolder.addArrangedSubview(timeLabel)
        timeHolder.addArrangedSubview(transportLabel)

        timeField.addArrangedSubview(actuallTime)
        timeField.addArrangedSubview(transportImage)

        addSubview(timeSelectButton)

        let offset:CGFloat = 16

        stackView.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview().offset(offset)
            make.top.equalToSuperview().offset(offset/2)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-offset/2)
        })
        transportImage.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(25)
        })
        timeSelectButton.snp.makeConstraints({ (make) -> Void in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(timeField)
            make.top.equalTo(timeHolder)
        })
    }
    func setPlan(in section:Int,_ row:Int,data:EachData,isEnabled:Bool){
        titleField.text = data.name
        detailField.text = data.detail
        addressField.text = data.address
        websiteField.text = data.website
        switch data.transport {
        case 0: transportImage.image = .carImage
        case 1: transportImage.image = .trainImage
        case 2: transportImage.image = .walkImage
        default: transportImage.image = .bookmark
        }
        reloadDateDuration(in: section, row, isEnabled: isEnabled)

        if data.website == String.empty && !isEnabled{
            websiteHolder.isHidden = true
            websiteField.isHidden = true
        }else{
            websiteHolder.isHidden = false
            websiteField.isHidden = false
        }
        if !isEnabled && data.detail == String.empty {
            detailHolder.isHidden = true
            detailField.isHidden = true
        }else{
            detailHolder.isHidden = false
            detailField.isHidden = false
        }

        if section == 0 && row == 0 {
            transportLabel.isHidden = true
            transportImage.isHidden = true
        }else{
            transportLabel.isHidden = false
            transportImage.isHidden = false
        }
    }
    private func reloadDateDuration(in section:Int,_ row:Int ,isEnabled:Bool){
        if section == 0 && row == 0 {
            timeLabel.text = "Departing date".localized
            actuallTime.text = s.dateAndTimeFormatter().string(from: d.data(at: section, row).time)
        }else if row == 0 {
            timeLabel.text = "Departing time".localized
            actuallTime.text = s.timeFormatter().string(from: d.data(at: section, row).time)
        }else{
            timeLabel.text = "Stay time".localized
            actuallTime.text = s.durationFormatter(time: d.data(at: section, row).timeIn)
        }
        setPlanIsEnabled(isEnabled: isEnabled)
    }
    private func setPlanIsEnabled(isEnabled:Bool){
        titleField.isEnabled = isEnabled
        detailField.isEnabled = isEnabled
        addressField.isEnabled = isEnabled
        timeSelectButton.isEnabled = isEnabled
        websiteField.isEnabled = isEnabled
    }
}
extension PlanDetailView:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == titleField {
            self.delegate?.setName(to: titleField.text ?? String.empty)
        } else if textField == detailField {
            self.delegate?.setDetail(to: detailField.text ?? String.empty)
        }else if textField == addressField {
            self.delegate?.setAddress(to: textField.text ?? String.empty)
        }else if textField == websiteField {
            self.delegate?.setWebsite(to: textField.text ?? String.empty)
        }else{
            ERROR("ERROR IN TEXTFIELD SELECTIONJ")
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
