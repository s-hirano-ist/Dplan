//
//  PlaceLocationView.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/30.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import MapKit
import SideMenu
import FloatingPanel
import DKImagePickerController

// for inits
class CandidateLocationView: UIViewController,UIScrollViewDelegate{
    let c = RealmCandidate()
    let s = Settings()
    private let searchCompleter = MKLocalSearchCompleter()

    private let edgeInsets = UIEdgeInsets(top: 44, left: 16, bottom: 34, right: 16)
    private let imageViewHeight:CGFloat = 275
    private let titleViewHeight:CGFloat = 86
    private var detailViewHeight:CGFloat = 86
    private let mapUIViewHeight:CGFloat = 500

    //parentViewと共有 要初期化
    var rows = Int()
    var state = State()

    var location: CLLocationCoordinate2D!

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.showsBookmarkButton = false
        searchBar.placeholder = "Search for a place or address".localized
        searchBar.showsSearchResultsButton = false
        searchBar.returnKeyType = .done
        searchBar.tintColor = R.color.mainGray()!
        searchBar.searchBarStyle = .minimal //???
        searchBar.enablesReturnKeyAutomatically = true
        return searchBar
    }()
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill //画面全体に 横方向
        stackView.distribution = .equalSpacing //DONOT CHANGE
        stackView.axis = .vertical
        return stackView
    }()
    private var searchTableView:SearchDestinationView!
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
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    lazy var imageView:ImageView = {
        let imageView = ImageView()
        imageView.delegate = self
        return imageView
    }()

    lazy var detailView:PlaceDetailView = {
        let detailView = PlaceDetailView()
        detailView.delegate = self
        return detailView
    }()
    lazy var mapUIView: MapUIView = {
        let mapUIView = MapUIView()
        return mapUIView
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
extension CandidateLocationView {
    private func setButtons(){
        if let button = buttonOne{ button.removeFromSuperview()}
        if let button = buttonThree{ button.removeFromSuperview()}
        if let button = buttonFour{ button.removeFromSuperview()}
        switch state{
        case .new:
            buttonThree = ButtonThreeView()
            buttonView.addSubview(buttonThree)
            buttonThree.snp.makeConstraints({ (make) -> Void in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(51)
            })
            buttonThree.delegate = self
            buttonThree.leftButton.setButton(title: "Cancel".localized)
            buttonThree.centerButton.disable()
            buttonThree.rightButton.setButton(title:"Add candidate".localized)
        case .edit:
            buttonOne = ButtonOneView()
            buttonView.addSubview(buttonOne)
            buttonOne.snp.makeConstraints({ (make) -> Void in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(51)
            })
            buttonOne.centerButton.setButton(title:"Done".localized)
            buttonOne.delegate = self
        case .show:
            buttonFour = ButtonFourView()
            buttonView.addSubview(buttonFour)
            buttonFour.snp.makeConstraints({ (make) -> Void in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(51)
            })
            buttonFour.oneButton.setButton(title: "Close".localized)
            buttonFour.twoButton.setButton(title:"Open in map app".localized)
            buttonFour.threeButton.setButton(title:"Add here to other data".localized)
            buttonFour.fourButton.setButton(title:"Edit destination".localized)
            buttonFour.delegate = self
        }
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
        let data = RealmCandidate().data(at: rows)
        imageView.setData(images: data.images, isEnabled: !(state == .show ))
        detailView.setPlace(with: data,isEnabled: !(state == .show ))
        location = data.location

        mapUIView.setMap(location: location)
        searchBar.isHidden = state == .show ? true : false
        searchTableView.view.isHidden = true
        setButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        updateAllView()
    }
}

//for first time only
extension CandidateLocationView{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = R.color.mainWhite()
        setConstraints()
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        searchCompleter.delegate = self
        searchBar.delegate = self
    }
    private func setConstraints(){
        view.addSubview(scrollView)
        view.addSubview(buttonView)

        scrollView.addSubview(stackView)

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

        searchTableView.view.snp.makeConstraints({ (make) -> Void in
            make.left.right.equalToSuperview()
            make.height.equalTo(400)
        })
        stackView.snp.makeConstraints({ (make) -> Void in
            make.bottom.top.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.width.equalTo(view)
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
//for searchBar
extension CandidateLocationView:UISearchBarDelegate,MKLocalSearchCompleterDelegate,CLLocationManagerDelegate {
    //データの保存なし そのままキーボードを閉じるのみ
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
    //Be AWARE of the error
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


//for buttons delegate
extension CandidateLocationView: ButtonThreeDelegate, ButtonOneViewDelegate,ButtonFourViewDelegate {
    //for edit
    //for reload and dismiss
    func onlyButtonClicked() {
        dismiss(animated: true, completion: nil)
    }
    //for show
    func oneButtonClicked() { //for dismiss
        dismiss(animated: true, completion: nil)
    }
    func twoButtonClicked() { //for map segue
        Segues().openGoogleMaps(withPlaceName: c.data(at: rows).name)
    }
    func threeButtonClicked() { //for add place to other data
    }
    func fourButtonClicked() { //edit
        state = .edit
        updateAllView()
    }
    //for new
    func leftButtonClicked() { //for delete and dismiss
        c.deleteCandidate(at: rows)
        dismiss(animated: true, completion: nil)
    }
    func centerButtonClicked() { //for new day
    }
    func rightButtonClicked() { //for save
        dismiss(animated: true, completion: nil)
    }
}
extension CandidateLocationView: PlaceDetailViewDelegate,SearchDestinationViewDelegate {
    func setLocation(location: CLLocationCoordinate2D) {
        c.setLocation(at: rows, location: location)
        mapUIView.setMap(location: location)
    }
    func setNameAndAddress(name: String, address: String) {
        c.setName(at: rows, name: name)
        c.setAddress(at: rows, address: address)
        imageView.isHidden = false
        detailView.isHidden = false
        mapUIView.isHidden = false
        searchTableView.view.isHidden = true
    }
    func setName(to data: String) {
        c.setName(at: rows, name: data)
    }
    func setDetail(to data: String) {
        c.setDetail(at: rows, detail: data)
    }
    func setAddress(to data: String) {
        c.setAddress(at: rows, address: data)
    }
    func setWebsite(to data: String) {
        c.setWebsite(at: rows, website: data)
    }
}

//for image page view
extension CandidateLocationView:ImagePageViewDelegate {
    func deleteImage(at index: Int) {
        DEBUG("DELETE IMAGE AT\(index)")
        c.removeImage(at: rows, index: index)
        let data = c.data(at: rows).images
        imageView.setData(images: data, isEnabled: true)
    }
    func editImage(of image: UIImage,index:Int) {
        c.overwriteImage(at: rows, image: image, at: index)
        let data = c.data(at: rows).images
        imageView.setData(images: data, isEnabled: true)
    }
}
// for DKImageSelector
extension CandidateLocationView: DKImageAssetExporterObserver,ImageViewDelegate{
    func activateImageView(page: Int,imageList:[UIImage]) {
        let view = R.storyboard.main.imagepagE()!
        view.modalPresentationStyle = .overFullScreen
        view.currentPage = page
        view.images = imageList
        view.canDelete = state != .show
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
                        RealmCandidate().appendImage(at: self.rows, image: image,at:counter)
                        let data = RealmCandidate().data(at: self.rows).images
                        self.imageView.setData(images: data, isEnabled: true)
                        counter+=1
                    })
                    //IMPROVE reload最中は変な操作をさせないための対処法 with 並立処理
                }
            }
        }
    }
}
