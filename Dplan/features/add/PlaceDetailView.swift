//
//  PlaceDetailView.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/30.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import Material
import SnapKit

protocol PlaceDetailViewDelegate {
    func setName(to data:String)->Void
    func setDetail(to data:String)->Void
    func setAddress(to data:String)->Void
    func setWebsite(to data:String)->Void
}

class PlaceDetailView: UIView {
    let s = Settings()
    var delegate: PlaceDetailViewDelegate?

    //var date:Date = Date()
    //var duration:Double = 0

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
        label.text = "Name".localized
        label.textColor = R.color.mainGray()!//
        return label
    }()
    lazy var titleField: UITextField = {
        let textField = s.textField()
        textField.delegate = self
        textField.textColor = R.color.mainBlack()!
        textField.font = .boldSystemFont(ofSize: 27)
        textField.placeholder = "Name of place".localized
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
        textField.placeholder = "Details".localized
        return textField
    }()
    lazy var addressHolder:UILabel = {
        let label = UILabel()
        label.fontSize = 10
        label.text = "Address".localized
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
        textField.placeholder = "Website".localized //
        return textField
    }()
    override init(frame: CGRect) {
        super.init(frame:frame)
        setConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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

        let offset:CGFloat = 16
        stackView.snp.makeConstraints({ (make) -> Void in
            make.left.equalToSuperview().offset(offset)
            make.top.equalToSuperview().offset(offset/2)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-offset/2)
        })
    }
}

extension PlaceDetailView {
    private func setPlaceIsEnabled(isEnabled:Bool){
        titleField.isEnabled = isEnabled
        detailField.isEnabled = isEnabled
        addressField.isEnabled = isEnabled
        websiteField.isEnabled = isEnabled
    }
}

//MARK: for sets from parent view
extension PlaceDetailView {
    func setPlace(with data:PlaceData,isEnabled:Bool){
        titleField.text = data.name
        detailField.text = data.detail
        addressField.text = data.address
        websiteField.text = data.website
        setPlaceIsEnabled(isEnabled: isEnabled)
        //!isEnabled == show
        if !isEnabled && data.website == String.empty{
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
    }
}

extension PlaceDetailView:UITextFieldDelegate {
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
            ERROR("ERROR IN TEXTFIELD SELECTION")
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

