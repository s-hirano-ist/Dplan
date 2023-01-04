//
//  PlanLocationView.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/30.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import MapKit
import SideMenu
import FloatingPanel
import DKImagePickerController
import SnapKit

//MARK: for inits
enum PlanState {
    case newPlan
    case newDay
    case newDest
    case edit
    case show
    init() {
        self = .show
    }
}

class PlanLocationView: UIViewController{
    private let d = RealmPlan()
    private let s = Settings()

    private let searchCompleter = MKLocalSearchCompleter()

    //parentViewと共有 要初期化
    var rows = Int()
    var sections = Int()
    var state = PlanState()

    var location: CLLocationCoordinate2D!
    var titleOfEvent:String? = nil

    //viewの定義
    private let datePicker = DatePickerView()
    private let floatingController = FloatingPanelController()

    lazy var titleOfEventView:UIView = {
        let v = UIView()
        v.layer.shadowOffset = CGSize(width: 0.0, height: 3)// 影の方向
        v.layer.shadowRadius = 1.5// 影をぼかし
        v.layer.shadowColor = R.color.mainGray()!.cgColor //影の色
        v.layer.shadowOpacity = 0.5// 影の濃さ
        v.backgroundColor = R.color.mainWhite()!
        return v
    }()
    lazy var titleField:UITextField = {
        let titleField = s.textField()
        titleField.placeholder = "Click to enter title".localized
        titleField.text = titleOfEvent
        titleField.delegate = self
        return titleField
    }()
    //MARK: IMPROVE if edit plan then get image from realm
    lazy var titleImageAddButton:UIButton = {
        let button = UIButton()

        button.fontSize = 10
        button.backgroundColor = R.color.mainLightGray()!
        button.cornerRadiusPreset = .cornerRadius3
        button.setTitleColor(R.color.mainBlack()!, for: .normal)
        button.addTarget(self,
                         action: #selector(addButtonPressed),
                         for: .touchUpInside)
        button.tintColor = R.color.mainBlack()!
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    var titleImagePicker:DKImagePickerController!
    @objc func addButtonPressed(_ sender: UIButton) {
        titleImagePicker = Settings().setImagePicker(singleSelect: true)
        titleImagePicker.exportStatusChanged = { status in
            switch status {
            case .exporting: DEBUG("exporting")
            case .none: DEBUG("none")
            }
        }
        titleImagePicker.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            self.updateTitleImage(assets: assets)
        }
        self.present(titleImagePicker, animated: true)
    }
    private func updateTitleImage(assets: [DKAsset]) {
        if titleImagePicker.exportsWhenCompleted {
            for asset in assets {
                if let error = asset.error {
                    ERROR("exporterDidEndExporting with error:\(error.localizedDescription)")
                } else {
                    asset.fetchOriginalImage(completeBlock:{image, info in
                        self.titleImageAddButton.setImage(image, for: .normal)
                        RealmPlan().setTitleImage(at: NUMBER, to: image)
                    })
                }
            }
        }
    }

    private var searchTableView:SearchDestinationView!

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill //画面全体に 横方向
        stackView.distribution = .equalSpacing //MARK: DONOT CHANGE
        stackView.axis = .vertical
        return stackView
    }()
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.showsBookmarkButton = false
        searchBar.placeholder = "Search for a place or address".localized
        searchBar.showsSearchResultsButton = false
        searchBar.returnKeyType = .done
        searchBar.tintColor = R.color.mainGray()!
        searchBar.searchBarStyle = .minimal //MARK: ???
        searchBar.enablesReturnKeyAutomatically = true
        return searchBar
    }()
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = false
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.isUserInteractionEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .never //safeArea計算は自分で
        //scrollView.backgroundColor = R.color.mainWhite()!
        //scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    lazy var imageView:ImageView = {
        let imageView = ImageView()
        imageView.delegate = self
        return imageView
    }()
    lazy var detailView:PlanDetailView = {
        let detailView = PlanDetailView()
        detailView.delegate = self
        return detailView
    }()
    lazy var mapUIView:MapUIView = {
       let mapView = MapUIView()
        return mapView
    }()

    lazy var buttonView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        return view
    }()

    private var pickerController: DKImagePickerController!

    var buttonOne:ButtonOneView!
    var buttonThree:ButtonThreeView!
    var buttonFour:ButtonFourView!
}
//MARK: only once
extension PlanLocationView {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = R.color.mainWhite()!
        addViews() //MARK: only once
        setConstraints() //MARK: only once
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        searchCompleter.delegate = self
        searchBar.delegate = self
        view.bringSubviewToFront(floatingController.view)
        prepareFloatingPannel()
    }
    private func addViews(){
        view.addSubview(scrollView)
        view.addSubview(buttonView)
        scrollView.addSubview(stackView)
        titleOfEventView.addSubview(titleField)
        titleOfEventView.addSubview(titleImageAddButton)

        stackView.addArrangedSubview(titleOfEventView)
        stackView.addArrangedSubview(searchBar)

        searchTableView = R.storyboard.main.searchView()!
        searchTableView.searchBar = searchBar
        searchTableView.searchCompleter = searchCompleter
        searchTableView.delegate = self
        self.addChild(searchTableView)
        searchTableView.didMove(toParent: self)
        stackView.addArrangedSubview(searchTableView.view)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(detailView)
        stackView.addArrangedSubview(mapUIView)
    }
    private func setConstraints(){
        let offset:CGFloat = 16
        searchTableView.view.snp.makeConstraints({ (make) -> Void in
            make.left.right.equalToSuperview()
            make.height.equalTo(400)
        })
        stackView.snp.makeConstraints({ (make) -> Void in
            make.bottom.top.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.width.equalTo(view)
        })

        titleOfEventView.snp.makeConstraints({ (make) -> Void in
            make.left.right.equalToSuperview()
            make.height.equalTo(32)
        })
        titleField.snp.makeConstraints({ (make) -> Void in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(offset)
            make.right.equalTo(titleImageAddButton.snp.left)
        })
        titleImageAddButton.snp.makeConstraints({ (make) -> Void in
            make.right.equalToSuperview().offset(-offset)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.width.equalTo(100)
        })
        searchBar.snp.makeConstraints({ (make) -> Void in
            make.right.left.equalToSuperview()
        })
        buttonView.snp.makeConstraints({ (make) -> Void in
            make.bottom.right.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-51)
        })
    }

}
//MARK: everytime
extension PlanLocationView {
    override func viewWillAppear(_ animated: Bool) {
        updateAllView()
        searchBar.showsCancelButton = false
        imageView.isHidden = false
        detailView.isHidden = false
        mapUIView.isHidden = false
        searchTableView.view.isHidden = true
    }
    private func updateAllView(){
        scrollView.snp.removeConstraints()
        scrollView.snp.makeConstraints({ (make) -> Void in
            make.right.left.equalToSuperview()
            make.bottom.equalTo(buttonView.snp.top)
            if self.state == .show {
                make.top.equalToSuperview()
            }else{
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            }
        })
        
        titleOfEventView.isHidden = (sections == 0 && rows == 0 && state != .show) ? false : true
        searchBar.isHidden = state == .show ? true : false
        searchTableView.view.isHidden = true

        let data = RealmPlan().data(at:sections,rows)
        imageView.setData(images: data.images, isEnabled: !(state == .show))
        detailView.setPlan(in: sections, rows, data: data, isEnabled: !(state == .show))
        location = data.location
        mapUIView.setMap(location: location)
        setButtons()
        if let image = RealmPlan().getTitleImage(at: NUMBER){
            titleImageAddButton.setImage(image , for: .normal)
        }else{
            titleImageAddButton.setTitle("Add title image".localized, for: .normal)
        }
    }

    private func setButtons(){
        if let button = buttonOne{ button.removeFromSuperview()}
        if let button = buttonThree{ button.removeFromSuperview()}
        if let button = buttonFour{ button.removeFromSuperview()}
        switch state{
        case .newPlan,.newDay,.newDest:
            buttonThree = ButtonThreeView()
            buttonView.addSubview(buttonThree)
            buttonThree.snp.makeConstraints({ (make) -> Void in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(51)
            })
            buttonThree.delegate = self
            buttonThree.setButtons(state: state)
        case .edit:
            buttonOne = ButtonOneView()
            buttonView.addSubview(buttonOne)
            buttonOne.snp.makeConstraints({ (make) -> Void in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(51)
            })
            buttonOne.delegate = self
        case .show:
            buttonFour = ButtonFourView()
            buttonView.addSubview(buttonFour)
            buttonFour.snp.makeConstraints({ (make) -> Void in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(51)
            })
            buttonFour.delegate = self
        }
    }
}

//MARK: for searchBar
extension PlanLocationView:UISearchBarDelegate,MKLocalSearchCompleterDelegate,CLLocationManagerDelegate,UIScrollViewDelegate {
    //MARK: データの保存なし そのままキーボードを閉じるのみ．
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        imageView.isHidden = false
        detailView.isHidden = false
        mapUIView.isHidden = false
        searchTableView.view.isHidden = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = String.empty
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        imageView.isHidden = false
        detailView.isHidden = false
        mapUIView.isHidden = false
        searchTableView.view.isHidden = true
        searchCompleter.queryFragment = String.empty
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool{
        searchBar.showsCancelButton = true
        imageView.isHidden = true
        detailView.isHidden = true
        mapUIView.isHidden = true
        searchTableView.view.isHidden = false
        return true
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.searchText()
        }
        return true
    }
    func searchText(){
        guard let text = self.searchBar.text else { return }
        self.searchCompleter.queryFragment = text
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchCompleter.queryFragment = String.empty
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchTableView.tableView.reloadData()
    }
    //MARK: Be AWARE of the error
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {
            return
        }
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        //キーボードの高さを取得
        guard let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if let searchTableView = searchTableView {
            searchTableView.view.frame = CGRect(x: 0,
                                                y: searchBar.frame.maxY,
                                                width: view.frame.width,
                                                height: rect.minY - searchBar.frame.maxY)
            UIView.animate(withDuration: duration , delay: 0.5, animations: {
                //キーボードぼ高さに応じた処理
            })
        }
    }
}

//MARK: for buttons delegate
extension PlanLocationView: ButtonThreeDelegate, ButtonOneViewDelegate,ButtonFourViewDelegate {
    //MARK: for edit
    func onlyButtonClicked() {
        //s.reloadMainBackgroundViewDismiss(controller: self)
        dismiss(animated: true, completion: nil)
    }
    //MARK: for show
    func oneButtonClicked() { //for dismiss
        //Settings().reloadMainBackgroundViewDismiss(controller: self)
        dismiss(animated: true, completion: nil)
    }
    func twoButtonClicked() { //for map segue
        Segues().openGoogleMaps(withPlaceName: d.data(at:sections,rows).name)
    }
    func threeButtonClicked() { //for add place to other data

    }
    func fourButtonClicked() { //to edit view
        state = .edit
        updateAllView()
    }
    //MARK: for new
    func leftButtonClicked() { //for delete and dismiss
        switch state {
        case .newDest: d.deleteRow(at: sections, rows)
        case .newDay: d.deleteSection(at: sections)
        case .newPlan: d.deletePlan(at: NUMBER)
        default: ERROR("ERROR")
        }
        dismiss(animated: true, completion: nil)
    }
    func centerButtonClicked() { //for new day
        let calendar = Calendar(identifier: .gregorian)
        let year = calendar.component(.year, from: d.data(at: sections, rows).time)
        let month = calendar.component(.month, from: d.data(at: sections, rows).time)
        let day = calendar.component(.day, from: d.data(at: sections, rows).time) + 1
        let data = d.data(at: sections, rows)
        d.deleteRow(at: sections, rows)
        d.saveNewDay()
        state = .newDay
        rows = 0
        sections = sections + 1
        d.setName(at: sections, rows, name: data.name)
        d.setLocation(at: sections, rows, location: data.location)
        d.setAddress(at: sections, rows, address: data.address)
        d.setDetail(at: sections, rows, detail: data.detail)
        d.setTimeToWithIsLocked(at: sections, rows, withTime: 0, isLocked: false, transport: data.transport)
        d.setWebsite(at: sections, rows, website: data.website)

        let date = calendar.date(from: DateComponents(year: year, month: month, day: day,hour: 8,minute: 00))
        d.setTime(at: sections, rows, time: date!)

        updateAllView()

        if let buttons = buttonThree {
            buttons.centerButton.disable()
        }
    }
    func rightButtonClicked() { //for save
        switch state {
        case .newPlan:
            /*if detailView.titleField.text == String.empty && detailView.addressField.text == String.empty{
                print("name,address not entered")
                return
            }
            if titleField.text == String.empty {
                print("title not entered")
                return
            }*/
            dismiss(animated: true, completion: nil)
        case .newDay,.newDest:
            /*if detailView.titleField.text == String.empty && detailView.addressField.text == String.empty{
                print("NOTHING ENTERED")
                return
            }*/
            dismiss(animated: true, completion: nil)
        default: ERROR("ERROR")
        }
    }
}
//MARK: for plan title label
extension PlanLocationView:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text{
            d.setTitle(at:NUMBER, to: text)
        }
    }
}
//MARK: sets delegate from subViews
extension PlanLocationView: SearchDestinationViewDelegate {
    func setLocation(location: CLLocationCoordinate2D) {
        d.setLocation(at: sections, rows, location: location)
        mapUIView.setMap(location: location)
    }
    func setNameAndAddress(name: String, address: String) {
        d.setName(at: sections, rows, name: name)
        d.setAddress(at: sections, rows, address: address)
        imageView.isHidden = false
        detailView.isHidden = false
        mapUIView.isHidden = false
        searchTableView.view.isHidden = true
    }
    func setName(to data: String) {
        d.setName(at: sections, rows, name: data)
    }
    func setDetail(to data: String) {
        d.setDetail(at: sections, rows, detail: data)
    }
    func setAddress(to data: String) {
        d.setAddress(at: sections, rows, address: data)
    }
    func setWebsite(to data: String) {
        d.setWebsite(at: sections, rows, website: data)
    }
    func setTransport(to data: Int) {
        d.setTransport(at: sections, rows, transport: data)
    }
}
//MARK: delegate from date picker view
extension PlanLocationView: PlanDetailViewDelegate, DatePickerDelegate{
    func closeDatePicker() {
        let data = RealmPlan().data(at:sections,rows)
        detailView.setPlan(in: sections, rows, data: data, isEnabled: true)
        floatingController.hide(animated: true){
            self.floatingController.didMove(toParent: self)
        }
    }
    func showTimePicker() {
        //MARK: resign all keyboards first
        titleField.resignFirstResponder()
        searchBar.resignFirstResponder()

        detailView.titleField.resignFirstResponder()
        detailView.detailField.resignFirstResponder()
        detailView.addressField.resignFirstResponder()
        detailView.websiteField.resignFirstResponder()

        datePicker.sections = sections
        datePicker.rows = rows

        if sections == 0 && rows == 0 {
            datePicker.state = .newPlan
        }else if rows == 0 {
            datePicker.state = .newDay
        }else{
            datePicker.state = .newDest
        }
        datePicker.setDatePicker()
        floatingController.show(animated: true) {
            self.floatingController.didMove(toParent: self)
        }
    }
}
//MARK: for image page view
extension PlanLocationView:ImagePageViewDelegate {
    func deleteImage(at index: Int) {
        DEBUG("DELETE IMAGE AT\(index)")
        d.removeImage(at: sections,rows,index: index)
        let data = d.data(at: sections, rows).images
        imageView.setData(images: data, isEnabled: true)
    }
    func editImage(of image: UIImage, index: Int) {
        DEBUG("overwrite image")
        d.overwriteImage(at: sections,rows, image: image, at: index)
        let data = d.data(at: sections, rows).images
        imageView.setData(images: data, isEnabled: true)
    }
}
// MARK: for DKImageSelector
extension PlanLocationView: DKImageAssetExporterObserver,ImageViewDelegate{
    func activateImageView(page: Int,imageList:[UIImage]) {
        let view = R.storyboard.main.imagepagE()!
        view.modalPresentationStyle = .overFullScreen
        view.currentPage = page
        view.images = imageList
        view.canDelete = state != .show
        view.canCrop = state != .show
        view.delegate = self
        self.present(view, animated: true, completion: nil)
    }
    func addImage() {
        pickerController = Settings().setImagePicker(singleSelect: false)
        pickerController.exportStatusChanged = { status in
            switch status {
            case .exporting: DEBUG("exporting")
            case .none: DEBUG("none")
            }
        }
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            self.updateImageViewImages(assets: assets)
        }
        self.present(pickerController, animated: true)
    }

    func updateImageViewImages(assets: [DKAsset]) {
        if pickerController.exportsWhenCompleted {
            var counter = 0
            for asset in assets {
                if let error = asset.error {
                    ERROR("exporterDidEndExporting with error:\(error.localizedDescription)")
                } else {

                    asset.fetchOriginalImage(completeBlock:{image, info in
                        RealmPlan().appendImage(at: self.sections, self.rows, image: image,at: counter)
                        //self.imageView.imageList.append(image)
                        let data = RealmPlan().data(at: self.sections, self.rows).images
                        self.imageView.setData(images: data, isEnabled: true)
                        counter+=1
                    })
                    //MARK: IMPROVE reload最中は変な操作をさせないための対処法 with 並立処理
                }
            }
        }
    }
}
//MARK: for date picker floatingPanel
extension PlanLocationView: FloatingPanelControllerDelegate{
    func prepareFloatingPannel(){
        setFloatingPannelx(controller: floatingController)
        floatingController.delegate = self
        datePicker.delegate = self
        floatingController.set(contentViewController: datePicker)
        floatingController.addPanel(toParent: self, belowView: nil, animated: true)
        floatingController.hide()
    }

    private func setFloatingPannelx(controller: FloatingPanelController){
        controller.surfaceView.shadowHidden = false
        controller.surfaceView.cornerRadius = 0.0
        controller.surfaceView.shadowHidden = false
        controller.isRemovalInteractionEnabled = false
        controller.surfaceView.grabberHandle.isHidden = true
        let backdropTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackdrop(tapGesture:)))
        controller.backdropView.addGestureRecognizer(backdropTapGesture)
        controller.view.frame = CGRect(x:0,y:0,width:view.frame.width,height:300)
        controller.delegate = self
    }
    @objc func handleBackdrop(tapGesture: UITapGestureRecognizer) {
        floatingController.hide(animated:true){
            self.floatingController.didMove(toParent: self)
        }
    }
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        floatingController.surfaceView.borderWidth = 0.0 //枠の太さ
        return HalfFloatingPannelLayout()
    }
    //MARK: tableView のスクロール 優先
    func floatingPanel(_ vc: FloatingPanelController, shouldRecognizeSimultaneouslyWith gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
        return true
    }
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
    }
    func floatingPanelDidMove(_ vc: FloatingPanelController) { //fade用
    }
}
