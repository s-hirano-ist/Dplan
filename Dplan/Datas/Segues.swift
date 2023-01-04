//
//  Segues.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/06.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import Foundation
import UIKit
import SideMenu
import MapKit
import Accounts
import RealmSwift
class Segues {
    private let s = Settings()
    private let d = RealmPlan()
    private let c = RealmCandidate()
    private let o = RealmOthers()
    
    func websiteSegue(in row:Int,state:URLState,controller:UIViewController){
        let view = R.storyboard.main.urlView()!
        switch state {
        case .editURL :
            view.firstData = o.getWebsite(at: row).website
            view.state = .others
        case .editURLCandidate:
            view.firstData = c.getWebsite(at: row).website
            view.state = .candidate
        case .newURL:
            view.firstData = "https://www.google.com".localized
            view.state = .others
        case .newURLCandidate:
            view.firstData = "https://www.google.com".localized
            view.state = .candidate
        }
        view.modalPresentationStyle = .overFullScreen
        controller.present(view, animated: true, completion: nil)
    }

//    func settingsSegue(controller:UIViewController){
//        let settingsView = R.storyboard.main.showStatusView()!
//        settingsView.modalPresentationStyle = .fullScreen
//        controller.present(settingsView,animated: true,completion: nil)
//    }

    func searchTableViewPopup(controller:UIViewController,searchBar:UISearchBar,searchCompleter:MKLocalSearchCompleter)-> SearchDestinationView {
        let searchTableView = R.storyboard.main.searchView()!
        //MARK: IMPROVE storyboard削除．

        searchTableView.searchBar = searchBar
        searchTableView.searchCompleter = searchCompleter
        //searchTableView.frameはkeyboard高さ取得メソッドによって定義
        controller.addChild(searchTableView)
        controller.view.addSubview(searchTableView.view)
        searchTableView.didMove(toParent: controller)
        return searchTableView
    }
}

//MARK: for mapApp segue
extension Segues {
    //MARK: IMPROVE クリップボードにlocをコピーして必要に応じて yahoo map 等に segue
    func copyLocation(){

    }
    func openGoogleMaps(withPlaceName placeName:String){
        let urlString: String!
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            urlString = "comgooglemaps://?q=\(placeName)".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        }
        else {
            ERROR("CANNOT OPEN USING GOOGLEMAPS")
            return
        }
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    func openGoogleMaps(withDestinationName destination:String,transport:Int){
        var transportString:String
        switch transport {
        case 0: transportString = "driving"
        case 1: transportString = "transit"
        case 2: transportString = "walking"
        default:
            transportString = "driving"
            ERROR("ERROR IN TRANSPORT SELECTION")
        }
        let urlString: String!
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            urlString = "comgooglemaps://?daddr=\(destination)&directionsmode=\(transportString)".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        }
        else {
            ERROR("CANNOT OPEN USING GOOGLEMAPS")
            return
        }
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    func openGoogleMaps(withCurrentLoc currentLoc:CLLocationCoordinate2D, destinationLoc:CLLocationCoordinate2D,transport:Int){
        var transportString:String
        switch transport {
        case 0: transportString = "driving"
        case 1: transportString = "transit"
        case 2: transportString = "walking"
        default:
            transportString = "driving"
            ERROR("ERROR IN TRANSPORT SELECTION")
        }
        let urlString: String!

        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            urlString = "comgooglemaps://?saddr=\(currentLoc.latitude),\(currentLoc.longitude)&daddr=\(destinationLoc.latitude),\(destinationLoc.longitude)&directionsmode=\(transportString)"
        }
        else {
            ERROR("CANNOT OPEN USING GOOGLEMAPS")
            return
        }
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
struct JsonPlanData: Codable {
    let title:String
    let detail:String
    let isFavorite:Bool
    let fileName:String
    let dayData:[DData]
    let place:[PData]
    let website:[WData]
}
struct DData:Codable {
    let eachData:[EData]
}
struct EData:Codable {
    let timeTo:Double
    let isLocked:Bool
    let timeIn:Double
    let time:Date
    let name:String
    let address:String
    let detail:String
    let latitude:Double
    let longitude:Double
    let transport:Int
    let website:String
    let imageList:[IData]
}
struct PData:Codable {
    let name:String
    let address:String
    let detail:String
    let latitude:Double
    let longitude:Double

    let website:String
    let category:String
    let isFavorite:Bool
    let imageList:[IData]
}
struct IData:Codable{
    let fileName:String
}
struct WData:Codable {
    let title:String
    let website:String
}

//MARK: for share segues
extension Segues {
    func convertFromJson(jsonData:String)->JsonPlanData{
        let data = try! JSONDecoder().decode(JsonPlanData.self,
                                                    from: jsonData.data(using: .utf8)!)
        return data
    }

    func sharePlanSegue(controller:UIViewController,num:Int){
        let fileName = "write.json"
        let d = convertFile(num: num)
        let data = try! JSONEncoder().encode(d)
        let text = String(data: data, encoding: .utf8)!
        let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first!
        let filePath = dir.appendingPathComponent( fileName )
        try! text.write( to: filePath, atomically: false, encoding: String.Encoding.utf8 )

        let activityViewController = UIActivityViewController(activityItems: [filePath],
                                                              applicationActivities: nil)
        controller.present(activityViewController, animated: true, completion: nil)
    }

    private func convertFile(num:Int)->JsonPlanData{
        let convertedData = planConvert(data: d.planList()[num])
        return convertedData
    }

    func imageTypeShare(image:UIImage,controller:UIViewController){
        let activityItems = [image] as [Any]
        let activityVC = UIActivityViewController(activityItems: activityItems,
                                                  applicationActivities: nil)
        let excludedActivityTypes = [
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.message]
        activityVC.excludedActivityTypes = excludedActivityTypes
        controller.present(activityVC, animated: true, completion: nil)
    }

    func webTypeShare(controller:UIViewController){
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle:  UIAlertController.Style.actionSheet)
        let appleMaps: UIAlertAction = UIAlertAction(
            title: "Open in Safari".localized,
            style: UIAlertAction.Style.default,
            handler:{
                (action: UIAlertAction!) -> Void in
                let view = controller as! WebsiteView
                if UIApplication.shared.canOpenURL(view.webView!.url!) {
                    UIApplication.shared.open(view.webView.url!)
                }
        })
        let shareDefault: UIAlertAction = UIAlertAction(
            title: "Share".localized,
            style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                self.shareWebsite(controller: controller)
        })
        let cancelAction: UIAlertAction = UIAlertAction(
            title: "Cancel".localized,
            style: UIAlertAction.Style.cancel,
            handler:{
                (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(appleMaps)
        alert.addAction(shareDefault)
        controller.present(alert, animated: true, completion: nil)
    }
    private func shareWebsite(controller:UIViewController){
        let view = controller as! WebsiteView
        if UIApplication.shared.canOpenURL(view.webView!.url!) {
            let website = view.webView!.url!
            let activityItems = [website] as [Any]
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            controller.present(activityVC, animated: true, completion: nil)
        }
    }
}

//MARK: for converts
extension Segues {
    private func planConvert(data:Plan)->JsonPlanData{
        return JsonPlanData(title: data.title,
                            detail: data.detail,
                            isFavorite: data.isFavorite,
                            fileName: data.fileName,
                            dayData: dayDataConvert(data: data.dayData),
                            place: placeDataConvert(data: data.place),
                            website: webDataConvert(data: data.website))
    }
    private func dayDataConvert(data:List<Daydata>)->[DData]{
        var dd:[DData] = []
        for d in data {
            dd.append(DData(eachData: eachDataConvert(data: d.eachData)))
        }
        return dd
    }
    private func eachDataConvert(data:List<EachData>)->[EData]{
        var dd:[EData] = []
        for d in data{
            let cData = EData(timeTo: d.timeTo,
                              isLocked: d.isLocked,
                              timeIn: d.timeIn,
                              time: d.time,
                              name: d.name,
                              address: d.address,
                              detail: d.detail,
                              latitude: d.latitude,
                              longitude: d.longitude,
                              transport: d.transport,
                              website: d.website,
                              imageList: imageDataConvert(data: d.imageList))
            dd.append(cData)
        }
        return dd
    }
    private func placeDataConvert(data:List<PlaceData>)->[PData]{
        var dd:[PData] = []
        for d in data {
            dd.append(PData(name: d.name,
                            address: d.address,
                            detail: d.detail,
                            latitude: d.latitude,
                            longitude: d.longitude,
                            website: d.website,
                            category: d.category,
                            isFavorite: d.isFavorite,
                            imageList: imageDataConvert(data: d.imageList)))
        }
        return dd
    }
    private func imageDataConvert(data:List<ImageData>)->[IData]{
        var dd:[IData] = []
        for d in data {
            dd.append(IData(fileName: d.fileName))
        }
        return dd
    }
    private func webDataConvert(data:List<URLData>)->[WData]{
        var dd:[WData] = []
        for d in data {
            dd.append(WData(title: d.title,
                            website: d.website))
        }
        return dd
    }
}
extension Segues {
    //MARK: append a new plan
    func setPlanDataJson(data:JsonPlanData){
        let jData = Plan(title: data.title,
                         detail: data.detail,
                         titleImage: nil,
                         isFavorite: data.isFavorite,
                         planList: dayDataJson(data: data.dayData),
                         URLList: webDataJson(data: data.website),
                         placeList: placeDataJson(data: data.place))
        RealmPlan().setNewPlan(data: jData)
    }

    private func dayDataJson(data:[DData])->[Daydata]{
        var dd:[Daydata] = []
        for d in data {
            dd.append(Daydata(eachList: eachDataJson(data: d.eachData)))
        }
        return dd
    }
    private func eachDataJson(data:[EData])->[EachData]{
        var dd:[EachData] = []
        for d in data {
            dd.append(EachData(timeTo: d.timeTo,
                               isLocked: d.isLocked,
                               timeIn: d.timeIn,
                               time: d.time,
                               name: d.name,
                               address: d.address,
                               detail: d.detail,
                               latitude: d.latitude,
                               longitude: d.longitude,
                               transport: d.transport,
                               website: d.website))
        }
        return dd
    }

    private func webDataJson(data:[WData])->[URLData]{
        var dd:[URLData] = []
        for d in data {
            dd.append((URLData(title: d.title,
                               website: d.website)))
        }
        return dd
    }

    //MARK: TODO image転送には未対応
    private func placeDataJson(data:[PData])->[PlaceData]{
        var dd:[PlaceData] = []
        for d in data {
            dd.append(PlaceData(name: d.name,
                                  address: d.address,
                                  detail: d.detail,
                                  latitude: d.latitude,
                                  longitude: d.longitude,
                                  website: d.website,
                                  category: d.category,
                                  isFavorite: d.isFavorite))
        }
        return dd
    }

}
