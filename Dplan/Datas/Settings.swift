//
//  Settings.swift
//  Dplan
//
//  Created by S.Hirano on 2019/12/18.
//  Copyright © 2019 Sola Studio. All rights reserved.
//
import Foundation
import UIKit
import Material
import RealmSwift
import SideMenu
import DKImagePickerController
import FloatingPanel
import MapKit

//FIXME: error handle
func ERROR(_ string:String){
    print(string)
}
func DEBUG(_ string:String){
    print(string)
}
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: String.empty)
    }
    static var empty: String {
        return ""
    }
}

extension UIImage {
    class var carImage: UIImage {
        return UIImage(systemName: "car.fill")!
    }
    class var trainImage: UIImage {
        return UIImage(systemName: "tram.fill")!
    }
    class var walkImage: UIImage {
        return UIImage(systemName: "tortoise.fill")!
    }
    class var star: UIImage {
        return UIImage(systemName: "star")!
    }
    class var starFill: UIImage {
        return UIImage(systemName: "star.fill")!
    }
    class var goBack: UIImage {
        return UIImage(systemName: "chevron.left")!
    }
    class var goForward: UIImage {
        return UIImage(systemName: "chevron.right")!
    }
    class var bookmark: UIImage {
        return UIImage(systemName: "bookmark")!
    }
    class var share: UIImage {
        return UIImage(systemName: "square.and.arrow.up")!
    }
    class var paperPlane:UIImage{
        return UIImage(systemName: "paperplane")!
    }
    class var mappin:UIImage{
        return UIImage(systemName:"mappin.circle")!
    }
    class var lockFill:UIImage{
        return UIImage(systemName:"lock.fill")!
    }
    class var globe:UIImage{
        return UIImage(systemName: "globe")!
    }
    
}
extension UIView {
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            guard let nextResponder = parentResponder?.next else { return nil }
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            parentResponder = nextResponder
        }
    }
    
    func parentView<T: UIView>(type: T.Type) -> T? {
        var parentResponder: UIResponder? = self
        while true {
            guard let nextResponder = parentResponder?.next else { return nil }
            if let view = nextResponder as? T {
                return view
            }
            parentResponder = nextResponder
        }
    }
}

struct DataCellSet {
    var name:String
    var detail:String
    var image:UIImage?
    var isSelected:Bool
    
    init(name:String,
         detail:String,
         image:UIImage?,
         isSelected:Bool) {
        self.name = name
        self.detail = detail
        self.image = image
        self.isSelected = isSelected
    }
    init() {
        self.name = String.empty
        self.detail = String.empty
        self.image = nil
        self.isSelected = false
    }
}

class Settings{
    //MARK: IMPROVE current localizationによって要変更
    let defaultLoc = CLLocationCoordinate2DMake(35.681114,139.766932)
}
//MARK: for formatter
extension Settings {
    func dateFormatter()->DateFormatter{
        let dateFormatter = DateFormatter()
        guard let formatString = DateFormatter.dateFormat(fromTemplate: "MMMdd",
                                                          options: 0,
                                                          locale: Locale.current)
        else { fatalError() }
        dateFormatter.dateFormat = formatString
        return dateFormatter
    }
    func dateAndTimeFormatter()->DateFormatter{
        let dateFormatter = DateFormatter()
        guard let formatString = DateFormatter.dateFormat(fromTemplate: "MMMdd-HH-mm",
                                                          options: 0,
                                                          locale: Locale.current)
        else { fatalError() }
        dateFormatter.dateFormat = formatString
        return dateFormatter
    }
    func timeFormatter()->DateFormatter{
        let dateFormatter = DateFormatter()
        guard let formatString = DateFormatter.dateFormat(fromTemplate: "HH-mm",
                                                          options: 0,
                                                          locale: Locale.current)
        else { fatalError() }
        dateFormatter.dateFormat = formatString
        return dateFormatter
    }
    func durationFormatter(time:Double)->String{
        let hour = Int(time/60/60)
        let min = Int(time/60)%60
        if hour == 0 && min == 0 {
            //return String.empty
            return "0" +  "hr".localized
        }else if min == 0{
            return String(hour) + "hr".localized
        }else if hour == 0{
            return String(min) + "min".localized
        }else{
            return String(hour) + "hr".localized + String(min) + "min".localized
        }
    }
    func convertedTime(planData:Plan)->String{
        let fromDate = planData.dayData[0].eachData[0].time
        let addDay = planData.dayData.count - 1
        let oneDay = DateComponents(day: addDay ,hour: 0, minute: 0)
        let toDate = Calendar.current.date(byAdding: oneDay, to: fromDate)!
        if addDay == 0{
            return dateFormatter().string(from: fromDate)
        }
        else{
            return dateFormatter().string(from: fromDate) + "〜".localized + dateFormatter().string(from: toDate)
        }
    }
}

//MARK: for buttons,textField
extension Settings {
    func flatButton(title:String,titleColor:UIColor)->FlatButton{
        let button = FlatButton()
        button.isEnabled = true
        //button.pulseColor = R.color.mainWhite()!
        button.pulseColor = R.color.mainLightGray()!
        button.backgroundColor = .clear
        button.isUserInteractionEnabled = true
        button.title = title
        button.titleColor = titleColor
        return button
    }
    func raisedButton()->RaisedButton{
        let button = RaisedButton()
        button.pulseColor = R.color.mainBlack()!
        button.tintColor = R.color.mainBlack()!
        button.backgroundColor = .clear
        return button
    }
    
    func textField()->UITextField{
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 8
        return textField
    }
    
    //MARK: for button in date,time picker
    func setButtonBackground(frame:CGRect)->UIView{
        let v = UIView(frame: frame)
        v.layer.shadowOffset = CGSize(width: 0.0, height: -2)// 影の方向
        v.layer.shadowRadius = 1.5// 影をぼかし
        v.layer.shadowColor = UIColor.gray.cgColor// 影の色
        v.layer.shadowOpacity = 0.5// 影の濃さ
        v.backgroundColor = .systemBackground
        return v
    }
    //MARK: for button in date,time picker
    func setButtonBackground()->UIView{
        let v = UIView()
        v.layer.shadowOffset = CGSize(width: 0.0, height: -2)// 影の方向
        v.layer.shadowRadius = 1.5// 影をぼかし
        v.layer.shadowColor = UIColor.gray.cgColor// 影の色
        v.layer.shadowOpacity = 0.5// 影の濃さ
        v.backgroundColor = .systemBackground
        return v
    }
    
    //MARK: for fabMenu
    func prepareFabMenuItemColors(item:FABMenuItem,icon:UIImage?,backgroundColor:UIColor){
        item.fabButton.tintColor = R.color.mainWhite()!
        item.fabButton.pulseColor = R.color.mainWhite()!
        item.titleLabel.backgroundColor = .clear
        item.titleLabel.textColor = R.color.mainBlack()!
        item.fabButton.backgroundColor = backgroundColor
        item.fabButton.image = icon
    }
    
    //MARK: for sideMenu settings
    func makeSettings(right :Bool,view:UIView) -> SideMenuSettings {
        //sideMenu settings
        //.menuSlideIn, .viewSlideOut, .viewSlideOutMenuIn, .menuDissolveIn
        let presentationStyle = right ?  SideMenuPresentationStyle.viewSlideOutMenuIn:SideMenuPresentationStyle.menuSlideIn
        presentationStyle.backgroundColor = R.color.mainBlack()!// 背景色
        presentationStyle.menuStartAlpha = CGFloat(1) //展開時の展開側のビューの透明度
        presentationStyle.menuScaleFactor = CGFloat(1)// 展開ビューの大きさの変化
        presentationStyle.onTopShadowOpacity = 0
        presentationStyle.presentingEndAlpha = CGFloat(1) //mainビューの透明度
        presentationStyle.presentingScaleFactor = CGFloat(1)
        
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.menuWidth = view.frame.width
        settings.blurEffectStyle = nil //nil, .dark, .light, .extraLight
        settings.statusBarEndAlpha = 0 // menu fade status bar
        
        settings.enableSwipeToDismissGesture = true //スワイプによる画面遷移禁止．
        return settings
    }
    func prepareRightView(view:UIView)->SideMenuNavigationController{
        let rightFabMenu = RightFabMenuView(rootViewController: RightCollectionView())
        let menu = SideMenuNavigationController(rootViewController: rightFabMenu)
        menu.setNavigationBarHidden(true, animated: false)
        menu.settings = makeSettings(right: true,view:view)
        menu.leftSide = false
        return menu
    }
    
    //MARK: for image Picker
    func setImagePicker(singleSelect:Bool)->DKImagePickerController {
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allPhotos
        pickerController.singleSelect = singleSelect
        pickerController.allowSwipeToSelect = true
        pickerController.showsCancelButton = true
        pickerController.exportsWhenCompleted = true
        pickerController.UIDelegate = CustomImagePickerDelegate()
        //pickerController.UIDelegate = AssetClickHandler() // for default if wanted
        return pickerController
    }
    
}

//MARK: for dismiss modal
extension Settings {
    func reloadRightViewDismiss(controller:UIViewController){
        if let view = controller.presentingViewController as? SideMenuNavigationController,
           let vv = view.children[0] as? RightFabMenuView,
           let v = vv.children[0] as? RightCollectionView {
            controller.dismiss(animated: true, completion: {
                v.adapter.performUpdates(animated: false, completion: nil)
            })
        }
    }
    /*func reloadMainBackgroundViewDismiss(controller:UIViewController){
     if let view = controller.presentingViewController as? MainBackgroundView {
     controller.dismiss(animated: true, completion: {
     view.updateMainView()
     })
     }
     }
     func reloadSideMenuDismiss(controller:UIViewController){
     if let view = controller.presentingViewController as? SideFabMenuView,
     let v = view.children[0] as? SideCollectionView{
     controller.dismiss(animated: true, completion: {
     v.adapter.performUpdates(animated: true, completion: nil)
     })
     }
     }
     func reloadSideMenuDismissPresent(controller:UIViewController){
     if let view = controller.presentingViewController as? SideFabMenuView,
     let v = view.children[0] as? SideCollectionView{
     v.adapter.performUpdates(animated: true, completion: nil)
     controller.dismiss(animated: true, completion: {
     v.planPressed(at: NUMBER)
     })
     }
     }*/
    
}
//MARK: for timePicker,datePicker view

var halfPositionHeight:CGFloat?

class HalfFloatingPannelLayout: FloatingPanelLayout{
    var supportedPositions: Set<FloatingPanelPosition> {
        return [.half]
    }
    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        //MARK:IMPROVE 厳密な値をセット．
        switch position {
        case .half:
            return halfPositionHeight ?? 300 // A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }
    
    var topInteractionBuffer: CGFloat {
        return 0 //上部に侵入可能であるかどうか
    }
    var bottomInteractionBuffer: CGFloat {
        return 0
    }
    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.4
    }
}
//MARK: for plan tableview
class PlanFloatingPannelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 0 // A top inset from safe area
        case .half: return halfPositionHeight ?? 300 // A bottom inset from the safe area
        case .tip: return 55 + 44 // A bottom inset from the safe area
        default: return nil // case .hidden: return nil`
        }
    }
    var topInteractionBuffer: CGFloat {
        return 0
    }
    var bottomInteractionBuffer: CGFloat {
        return 0
    }
    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {//背景の透明度
        return 0.0
    }
}
class MyAnnotation: NSObject, MKAnnotation {
    static let ident = "myPin"
    let coordinate: CLLocationCoordinate2D
    let glyphText: String
    let glyphTintColor: UIColor
    let markerTintColor: UIColor
    let section:Int
    let row:Int
    var title:String?
    init(coordinate: CLLocationCoordinate2D,
         title:String,
         section:Int,
         row:Int,
         glyphText: String,
         glyphTintColor: UIColor,
         markerTintColor: UIColor) {
        self.title = title
        self.section = section
        self.row = row
        self.coordinate = coordinate
        self.glyphText = glyphText
        self.glyphTintColor = glyphTintColor
        self.markerTintColor = markerTintColor
    }
}
