//
//  MainBackgroundView.swift
//  DraPla05
//
//  Created by S.Hirano on 2019/08/30.
//  Copyright © 2019 Sola Studio. All rights reserved.
//

import UIKit
import FloatingPanel
import MapKit
import Motion
import SideMenu
import SnapKit
import Material

var polyline:[MKPolyline] = [] // polylineの描写用．
let bottomBarHeight:CGFloat = 44
let topBarHeight:CGFloat = 50

class MainBackgroundView: UIViewController {
    
    var locationManager: CLLocationManager!

    var beforeSection = 0 //MARK: 以前選択していたsection, rowを保存
    var beforeRow = 0
    var lines:[MKPolyline] = [] //MARK: 直近のルート全部を保存
    var centerOfMap:CLLocationCoordinate2D! //MARK: マップの中心地
    var regionOfMap: MKCoordinateRegion! //MARK: マップの倍率

    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.overrideUserInterfaceStyle = .light //常にlightMode
        mapView.mapType = .standard
        mapView.showsUserLocation = false
        mapView.isRotateEnabled = true
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.delegate = self
        mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - bottomBarHeight)
        return mapView
    }()
    
    lazy var bottomView:UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemGray5
        return backgroundView
    }()
    
    lazy var addButton: FABButton = {
        let button = FABButton(image: Icon.cm.share, tintColor: R.color.mainGray()! )
        button.pulseColor = R.color.mainWhite()!
        button.image = Icon.icon("ic_add_white")
        button.tintColor = R.color.mainWhite()!
        button.backgroundColor = R.color.subNavy()!
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addButtonPressed(gestureRecognizer:))))
        return button
    }()
    @objc func addButtonPressed(gestureRecognizer:UIGestureRecognizer) {
        print("ADD BUTTON PRESSED")
        let d = RealmPlan()
        let row =  d.countLastDestination(at: NUMBER)
        let section = d.countDays(at: NUMBER) - 1
        //MARK: 事前にプランオブジェクトを作成しておく
        d.saveExistDay()
        d.setTime(at: section, row, time: d.data(at:section,row-1).time)
        collectionView.presentPlanLocationView(at: section, row, state: .newDest)
    }
    
    lazy var toSideMenuButton: FABButton = {
        let button = FABButton()
        button.tintColor = R.color.mainWhite()!
        button.backgroundColor = R.color.subNavy()!
        button.setImage(UIImage(systemName: "house.fill"), for: .normal)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(showSideMenuClicked(gestureRecognizer:))))
        return button
    }()
    @objc func showSideMenuClicked(gestureRecognizer:UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    lazy var toRightViewButton: RaisedButton = {
        let button = Settings().raisedButton()
        button.tintColor = R.color.mainBlack()!
        button.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(showRightViewClicked(gestureRecognizer:))))
        return button
    }()
    @objc func showRightViewClicked(gestureRecognizer:UIGestureRecognizer) {
        present(rightView, animated: true, completion: nil)
    }
    lazy var editButton: RaisedButton = {
        let button = Settings().raisedButton()
        button.titleColor = R.color.mainBlack()!
        button.setTitle("Edit".localized, for: .normal)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(editButtonPressed(gestureRecognizer:))))
        return button
    }()
    @objc func editButtonPressed(gestureRecognizer:UIGestureRecognizer) {
        if !collectionView.isEditing {
            floatingPanelController.move(to: .full, animated: true)
            collectionView.collectionView.frame.size.height = collectionView.view.frame.height - self.view.safeAreaInsets.top - bottomBarHeight - topBarHeight + 8
            editButton.title = "Done".localized
        }else{
            editButton.title = "Edit".localized
        }
        collectionView.isEditing.toggle()
        collectionView.adapter.performUpdates(animated: true, completion: nil)
    }
    func floatingPanelShouldBeginDragging(_ vc: FloatingPanelController) -> Bool {
        //MARK: for fill 固定
        return collectionView.isEditing ?  false : true
    }
    lazy var showCurrentButton:MKUserTrackingButton = {
        let button = MKUserTrackingButton(mapView: mapView)
        button.tintColor = R.color.mainBlack()!
        return button
    }()
    lazy var showCompassButton:MKCompassButton = {
        let showCompassButton = MKCompassButton(mapView: mapView)
        showCompassButton.compassVisibility = .adaptive
        return showCompassButton
    }()
    lazy var scaleView:MKScaleView = {
        return MKScaleView(mapView: mapView)
    }()
    private var floatingPanelController = FloatingPanelController()
    lazy var collectionView:MainCollectionView = {
        let collectionView = MainCollectionView()
        collectionView.delegate = self
        setFloatingPannel(controller: floatingPanelController)
        floatingPanelController.set(contentViewController: collectionView)
        return collectionView
    }()
    private var timePickerFloatingController:FloatingPanelController!
    private var timePickerView = TimePickerView()
    lazy var rightView:SideMenuNavigationController = {
        let rightView = Settings().prepareRightView(view: self.view)
        return rightView
    }()
}
//MARK: only once
extension MainBackgroundView {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = R.color.mainWhite()!

        //halfPositionHeight = view.frame.height/5*2 //MARK: modalViewの .half高さを定義
        halfPositionHeight = 325 //MARK: 固定しないと4.7inch iphoneでボタン領域が表示されない constraints関係

        setBackgroundItems()
        floatingPanelController.addPanel(toParent: self, belowView: nil, animated: true)
        SideMenuManager.default.rightMenuNavigationController = rightView
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view, forMenu: .right)
        setFrontItems()
        prepareHalfFloatingPannel()//MARK: after other views
    }
}

//MARK: everytime
extension MainBackgroundView {
    //MARK: View更新処理全般
    func reloadView() {
        DEBUG("collectionView RELOAD compilation")
        collectionView.reloadLabel()
        collectionView.adapter.performUpdates(animated: true, completion: nil)
        setCenterOfMap()
        reloadMap()
    }
    //MARK: 非同期でクルクル更新処理
    func updateMainView(){
        collectionView.collectionView.refreshControl?.beginRefreshing()
        RealmPlan().reload(completion: {
            self.reloadView()
            self.collectionView.collectionView.refreshControl?.endRefreshing()
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let d = RealmPlan()
        if d.countDays(at: NUMBER) == 0 {
            dismiss(animated: false, completion: nil)
        }else if d.countDestination(at: NUMBER, in: 0) == 1 {
            reloadView() //まずは情報更新
            updateMainView() //非同期でリロード 必要なし．必ず以前データのロードを実行済．
            activateLocationManager()
            goToCenterOfMap()
            return
        }else{
            reloadView() //まずは情報更新
            updateMainView() //非同期でリロード 必要なし．必ず以前データのロードを実行済．
            activateLocationManager()
            goToCenterOfMap()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        //floatingPanelController.move(to: .half, animated: true)
        mapView.frame.origin.y = (floatingPanelController.originYOfSurface(for: .half) - floatingPanelController.originYOfSurface(for: .tip))/2
    }
    func activateLocationManager(){
        //TODO: DEBUG シミュレーション環境では利用不能
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status != CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }else{
            DEBUG("location enabled")
        }
        locationManager.startUpdatingLocation()
    }
    
    //MARK: mapviewが取り残されて削除されることを防ぐ
    override func viewWillDisappear(_ animated: Bool) {
        mapView.frame.origin.y = 0
    }
}

//MARK: for mapview
extension MainBackgroundView:CLLocationManagerDelegate,MKMapViewDelegate,MKLocalSearchCompleterDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)

        guard let markerAnnotationView = annotationView as? MKMarkerAnnotationView,
            let myAnnotation = annotation as? MyAnnotation else { return annotationView }

        markerAnnotationView.glyphText = myAnnotation.glyphText
        markerAnnotationView.markerTintColor = myAnnotation.markerTintColor
        markerAnnotationView.glyphTintColor = myAnnotation.glyphTintColor

        markerAnnotationView.clusteringIdentifier = MyAnnotation.ident
        //markerAnnotationView.clusteringIdentifier = nil //ピンのまとめ機能 なし
        markerAnnotationView.isDraggable = false
        markerAnnotationView.canShowCallout = true //吹き出し可能
        markerAnnotationView.collisionMode = .circle
        markerAnnotationView.titleVisibility = .visible
        markerAnnotationView.subtitleVisibility = .hidden
        markerAnnotationView.displayPriority = .required

        markerAnnotationView.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
        return markerAnnotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MyAnnotation {
            if (control == view.rightCalloutAccessoryView) {
                collectionView.presentPlanLocationView(at: annotation.section,
                                                       annotation.row,
                                                       state: .show)
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = overlay as? MKPolyline{
            let routeRenderer: MKPolylineRenderer = MKPolylineRenderer(polyline: route)
            routeRenderer.lineWidth = 8.0
            routeRenderer.strokeColor = R.color.routeCyan()!
            return routeRenderer
        }
        ERROR("ERROR in MKmapView render for")
        return MKOverlayRenderer()
    }

    private func reloadMap(){
        let d = RealmPlan()
        mapView.removeAnnotations(mapView.annotations)
        for section in 0 ..< d.countDays(at:NUMBER) {
            for row in 0 ..< d.countDestination(at: NUMBER, in: section) {
                let color:UIColor!
                if section == 0 { color = R.color.subNavy()!
                }else if section == 1 { color = R.color.subBlue()!
                }else { color = R.color.subRed()! }
                let data = d.data(at: section, row)
                let pin = MyAnnotation(coordinate: data.location,
                                       title: data.name,
                                       section: section,
                                       row: row,
                                       glyphText: String(row+1),
                                       glyphTintColor: R.color.mainWhite()!,
                                       markerTintColor: color)
                self.mapView.addAnnotation(pin)
            }
        }
        resetAllPolylines()
    }

    private func resetAllPolylines(){
        mapView.removeOverlays(lines)
        lines = polyline
        beforeSection = 0
        beforeRow = 0
        mapView.addOverlays(polyline)
        setCenterOfMap()
        goToCenterOfMap()
    }
    private func setTwoDestCenter(at section:Int,_ row:Int){
        let fromDest:CLLocationCoordinate2D!
        let toDest:CLLocationCoordinate2D!
        let d = RealmPlan()
        
        if row == 0 {
            fromDest = d.data(at: section-1, d.countDestination(at: NUMBER, in:section-1)-1).location
            toDest = d.data(at: section, 0).location
        }else{
            fromDest = d.data(at: section, row-1).location
            toDest = d.data(at: section, row).location
        }
        let latitude = (fromDest.latitude+toDest.latitude)/2
        let longitude = (fromDest.longitude+toDest.longitude)/2

        centerOfMap = CLLocationCoordinate2DMake(latitude, longitude)
        let dis = distance(current: (fromDest.latitude,fromDest.longitude),
                         target: (toDest.latitude,toDest.longitude))
        regionOfMap = MKCoordinateRegion(center: centerOfMap, latitudinalMeters: dis, longitudinalMeters: dis)
    }

    private func setCenterOfMap(){
        let d = RealmPlan()
        let s = Settings()
        var minLatitude = d.data(at: 0, 0).latitude==0.0 ? s.defaultLoc.latitude : d.data(at:0,0).latitude
        var maxLatitude = d.data(at: 0, 0).latitude==0.0 ? s.defaultLoc.latitude : d.data(at:0,0).latitude
        var minLongitude = d.data(at: 0, 0).longitude==0.0 ? s.defaultLoc.longitude : d.data(at:0,0).longitude
        var maxLongitude = d.data(at: 0, 0).longitude==0.0 ? s.defaultLoc.longitude : d.data(at:0,0).longitude
        for plan in d.plan(){
            for data in plan.eachData{
                if minLatitude > data.latitude && data.latitude != 0.0{
                    minLatitude = data.latitude
                }
                if maxLatitude < data.latitude && data.latitude != 0.0{
                    maxLatitude = data.latitude
                }
                if minLongitude > data.longitude && data.longitude != 0.0{
                    minLongitude = data.longitude
                }
                if maxLongitude < data.longitude && data.longitude != 0.0{
                    maxLongitude = data.longitude
                }
            }
        }

        centerOfMap = CLLocationCoordinate2D(latitude: (minLatitude+maxLatitude)/2,
                                             longitude: (minLongitude+maxLongitude)/2)
        let dis = distance(current: (minLatitude,minLongitude), target: (maxLatitude,maxLongitude))
        if RealmPlan().countDestination(at: NUMBER, in: 0) == 1{
            //目的地1つの場合
            regionOfMap = MKCoordinateRegion(center: centerOfMap, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        }else{
            regionOfMap = MKCoordinateRegion(center: centerOfMap, latitudinalMeters: dis, longitudinalMeters: dis)
        }
    }
    func distance(current: (la: Double, lo: Double), target: (la: Double, lo: Double)) -> Double {
        let currentLa   = current.la * Double.pi / 180
        let currentLo   = current.lo * Double.pi / 180
        let targetLa    = target.la * Double.pi / 180
        let targetLo    = target.lo * Double.pi / 180
        let equatorRadius = 6378137.0;
        let averageLat = (currentLa - targetLa) / 2
        let averageLon = (currentLo - targetLo) / 2
        let distance = equatorRadius * 2 * asin(sqrt(pow(sin(averageLat), 2) + cos(currentLa) * cos(targetLa) * pow(sin(averageLon), 2)))
        return distance*1.2
    }

    private func goToCenterOfMap(){
        mapView.setCenter(centerOfMap, animated: true)
        mapView.setRegion(regionOfMap, animated:true)
    }
}

//MARK: for delegate
extension MainBackgroundView: MainCollectionViewDelegate,TimePickerDelegate{
    func closeTimePicker() {
        timePickerFloatingController.hide(animated: true){
            self.timePickerFloatingController.didMove(toParent: self)
        }
        collectionView.adapter.performUpdates(animated: true, completion: nil)
        addButton.isHidden = false
    }
    func showTimePicker(at section: Int, _ row: Int) {
        addButton.isHidden = true
        timePickerView.sections = section
        timePickerView.rows = row
        timePickerView.setDatePicker()
        timePickerFloatingController.show(animated: true) {
            self.timePickerFloatingController.didMove(toParent: self)
        }
    }
    //MARK: dismiss mainView for DELETE PLANS
    func dismissActivate() {
        dismiss(animated: true, completion: nil)
    }
    //MARK: time clicked for show time on map
    func timeClicked(at section: Int, _ row: Int) {
        if section == beforeSection && row == beforeRow {
            resetAllPolylines()
        }else{
            mapView.removeOverlays(lines)
            lines = polyline
            beforeSection = section
            beforeRow = row
            mapView.addOverlay(polyline[ RealmPlan().calculateIndexPath(at:NUMBER, indexPath: IndexPath(row: row, section: section))-1])
            setTwoDestCenter(at: section, row)
            goToCenterOfMap()
        }
        floatingPanelController.move(to: .half, animated: true)
    }
}

//MARK: for two modal views
extension MainBackgroundView: FloatingPanelControllerDelegate {
    private func prepareHalfFloatingPannel(){
        //fabMenuBacking = .blur
        timePickerFloatingController = FloatingPanelController()
        setFloatingPannelx(controller: timePickerFloatingController)
        timePickerFloatingController.delegate = self
        timePickerView.delegate = self
        timePickerFloatingController.set(contentViewController: timePickerView)
        timePickerFloatingController.addPanel(toParent: self, belowView: nil, animated: true)
        timePickerFloatingController.hide()
    }
    private func setFloatingPannelx(controller: FloatingPanelController){
        controller.surfaceView.shadowHidden = false
        controller.surfaceView.cornerRadius = 0.0
        controller.surfaceView.shadowHidden = false
        controller.isRemovalInteractionEnabled = false
        controller.surfaceView.grabberHandle.isHidden = true
        let backdropTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleBackdrop(tapGesture:)))
        controller.backdropView.addGestureRecognizer(backdropTapGesture)
        controller.view.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:300)
        controller.delegate = self
    }
    @objc func handleBackdrop(tapGesture: UITapGestureRecognizer) {
        timePickerFloatingController.hide(animated:true){
            self.timePickerFloatingController.didMove(toParent: self)
        }
    }
    private func setFloatingPannel(controller: FloatingPanelController){
        controller.surfaceView.cornerRadius = 9.0
        controller.delegate = self
        controller.surfaceView.backgroundColor = .clear
        controller.surfaceView.shadowHidden = false
        controller.view.frame = view.bounds // MUST
    }
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        vc.surfaceView.borderWidth = 0.0 //枠の太さ
        if vc == timePickerFloatingController{
            return HalfFloatingPannelLayout()
        }
        return PlanFloatingPannelLayout()
    }

    func floatingPanel(_ vc: FloatingPanelController, shouldRecognizeSimultaneouslyWith gestureRecognizer: UIGestureRecognizer) -> Bool {
        if vc == timePickerFloatingController {
            return false //tableView のスクロール 優先
        }
        return false //tableView のスクロール 優先
    }
    func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
        return true
    }
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        collectionView.collectionView.frame.size.height = collectionView.view.frame.height - collectionView.line.frame.maxY
    }

    //MARK: sets for floating Pannel positions
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        if vc == timePickerFloatingController{ return }

        //mapView.frame.origin.y = (vc.surfaceView.frame.origin.y - vc.originYOfSurface(for: .tip))/2
        switch targetPosition {
        case .full:
            collectionView.collectionView.frame.size.height = collectionView.view.frame.height - self.view.safeAreaInsets.top - bottomBarHeight - topBarHeight + 8
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: .allowUserInteraction,
                           animations: {
                            self.mapView.frame.origin.y = (vc.originYOfSurface(for: .full) - vc.originYOfSurface(for: .tip))/2
            }, completion: nil)
        case .half:
            if let height = halfPositionHeight {
                collectionView.collectionView.frame.size.height = height - topBarHeight - bottomBarHeight
            }else{
                ERROR("ERROR IN SET OF HEIGHT")
                collectionView.collectionView.frame.size.height = 300 - topBarHeight - bottomBarHeight
            }
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: .allowUserInteraction,
                           animations: {
                            self.mapView.frame.origin.y = (vc.originYOfSurface(for: .half) - vc.originYOfSurface(for: .tip))/2
            }, completion: nil)
        case .tip:
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: .allowUserInteraction,
                           animations: {
                            self.mapView.frame.origin.y = 0
            }, completion: nil)
        default:
            break
        }
        //MARK: DO NOT ADD contentVC.tableView.reloadData()
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        self.collectionView.collectionView.alpha = targetPosition == .tip ? 0.0 : 1.0
                        //self.collectionView.dateLabel.alpha = targetPosition == .tip ? 0.0 : 1.0
                        self.collectionView.shareButton.alpha = targetPosition == .tip ? 0.0 : 1.0
                        //self.collectionView.titleField.frame.origin.x = targetPosition == .tip ? 64 : 16
        }, completion: nil)
    }
    func floatingPanelDidMove(_ vc: FloatingPanelController) { //fade用
        if vc == timePickerFloatingController{
            return
        }
        let y = vc.surfaceView.frame.origin.y
        let tipY = vc.originYOfSurface(for: .tip)
        let progress = max(0.0, min((tipY  - y) / 50.0, 1.0))
        if y > tipY - 50.0 {
            self.collectionView.collectionView.alpha = progress
            //self.collectionView.dateLabel.alpha = progress
            self.collectionView.shareButton.alpha = progress
            //self.collectionView.titleField.frame.origin.x = 16 + (1 - progress) * (64-16)
        }
        //MARK: y-tipY = どのくらい上に移動したか? 基本的に負の値
        self.mapView.frame.origin.y = (y-tipY)/2
    }
}

//MARK: for sideMenu
extension MainBackgroundView: SideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
    }
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
    }
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
    }
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
    }
}

//MARK: constraints
extension MainBackgroundView {
    private func setBackgroundItems(){

        view.addSubview(mapView)
        view.addSubview(scaleView)
        view.addSubview(showCurrentButton)
        view.addSubview(showCompassButton)
        view.addSubview(toSideMenuButton)

        //            bannerView.snp.makeConstraints({ (make) -> Void in
        //                make.right.equalToSuperview().offset(-8)
        //                make.left.equalToSuperview().offset(8)
        //                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        //                make.height.equalTo(0)
        //            })

        toSideMenuButton.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(44)
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        })
        
        showCurrentButton.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(44)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        })
        
        showCompassButton.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(44)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(showCurrentButton.snp.bottom)
        })
        
        scaleView.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(10)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(view.frame.width/3*2)
        })
    }
    private func setFrontItems(){
        view.addSubview(bottomView)
        bottomView.addSubview(toRightViewButton)
        bottomView.addSubview(editButton)

        view.addSubview(addButton)
        bottomView.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(44)
            make.left.right.equalToSuperview()
        })

        addButton.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(56)
            make.right.bottom.equalToSuperview().offset(-16)
        })
        toRightViewButton.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(44)
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
        })
        editButton.snp.makeConstraints({ (make) -> Void in
            make.width.equalTo(56)
            make.height.equalTo(44)
            make.left.equalTo(toRightViewButton.snp.right)
            make.top.equalToSuperview().offset(8)
        })
    }

}



//    func addBannerViewToView() {
//        adView = GADBannerView(adSize: kGADAdSizeBanner)
//        adView.adUnitID = "ca-app-pub-4476878961223776/7612061551" //real
//        //adView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //test
//        adView.rootViewController = self
//        adView.load(GADRequest())
//        bannerView.addSubview(adView)
//        adView.snp.makeConstraints({ (make) -> Void in
//            make.centerX.equalToSuperview()
//        })
//    }
//var bannerView: UIView = {
//    let view = UIView()
//    view.backgroundColor = .clear
//    return view
//}() //MARK: 広告表示の領域確保のみ
//    var adView:GADBannerView! //MARK: 広告表示欄



//        view.addSubview(bannerView)
//        if UserDefaults.standard.bool(forKey: "premiumFeatures") == false { //MARK: 広告あり
//            addBannerViewToView()
//            bannerView.snp.makeConstraints({ (make) -> Void in
//                make.right.equalToSuperview().offset(-8)
//                make.left.equalToSuperview().offset(8)
//                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//                make.height.equalTo(50)
//            })
//        }else{ //MARK: 広告なし
//            bannerView.snp.makeConstraints({ (make) -> Void in
//                make.right.equalToSuperview().offset(-8)
//                make.left.equalToSuperview().offset(8)
//                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//                make.height.equalTo(0)
//            })
//        }
