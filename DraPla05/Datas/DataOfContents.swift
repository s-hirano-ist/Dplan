//
//  DataOfContents.swift
//  DraPla05
//
//  Created by S.Hirano on 2019/08/23.
//  Copyright © 2019 Sola_studio. All rights reserved.
//
/* 最終的に除去
 UIFileSharingEnabled (Application supports iTunes file sharing)
 LSSupportsOpeningDocumentsInPlace (Supports opening documents in place)
 自分で撮影した画像 以外のデータ
 */

/* MARK: 注意事項まとめ
 * constraintsは lazyには記載せず、まとめて1つのメソッドで記述する．
 * buttons.set() は viewDidlayoutSubviews()実行後にする．
 * timeTo 23時間50分 = 0分．
 *        00時間00分 = 未定義/探索不能．
 * PlanTableModalView.collectionView constraints設定で優先されるためcollectionViewサイズ変更不可.
 * do not add tableView.reloadData() while moving cells or transision of modal view.
 * do not viewwillappear tableview.reload which deletes all non-saved data.
 * collectionView: estimated size = none OR ERROR OCCUR
 */

/* MARK: 不明点
 * tableView.rowHeight = UITableView.automaticDimension// cellの高さ可変??
 * tableView.estimatedRowHeight = 100 ??
 */

/* MARK: IMPROVE
 * 画像をgoogle検索し，候補を 写真のセレクト画面に同時に表示．
 * url画面から検索し、住所を取得しそれを新規日付画面に反映させる
 * offline 通知, reloadエラー，目的地エラー通知．
 * 初期設定としてsampleを作成
 * recently deleted 実装
 */

import RealmSwift
import MapKit
import IGListKit

var NUMBER = 0
var isCalculating = false //計算を実行しているかどうかの判定

extension Object: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}

//MARK: for candidate
class Candidate:Object {
    let place = List<PlaceData>()
    let text = List<TextData>()
    let website = List<URLData>()

    convenience init(textList:[TextData],
                     URLList:[URLData],
                     placeList:[PlaceData]){
        self.init()
        for text in textList {
            self.text.append(text)
        }
        for place in placeList{
            self.place.append(place)
        }
        for URL in URLList{
            self.website.append(URL)
        }
    }
}

//MARK: for plan
class Plan :Object {
    //TODO: 要リファクタリング 名称
    
    let dayData = List<Daydata>()
    let place = List<PlaceData>()
    let website = List<URLData>()
    @objc dynamic var title:String = String.empty
    @objc dynamic var detail:String = String.empty //equals text note
    @objc dynamic var isFavorite:Bool = false
    @objc dynamic var fileName:String = ""

    
    override static func ignoredProperties() -> [String] {
        return ["image","websiteDatas"]
    }
    
    convenience init(title:String,
                     detail:String,
                     titleImage: UIImage?,
                     isFavorite:Bool,
                     planList:[Daydata],
                     URLList:[URLData],
                     placeList:[PlaceData]){
        self.init()
        self.detail = detail
        self.title = title
        self.image = titleImage

        self.isFavorite = isFavorite
        for plan in planList {
            self.dayData.append(plan)
        }
        for place in placeList{
            self.place.append(place)
        }
        for URL in URLList{
            self.website.append(URL)
        }
    }
    
    //MARK: 取得用
     dynamic var websiteDatas:[URLData?]{
         get{
             var data:[URLData?] = []
             for d in website {
                 data.append(d)
             }
             return data
         }
     }
     
     dynamic var image:UIImage? {
         get{
             var dir = FileManager.default.urls( for: .documentDirectory,
                                                 in: .userDomainMask).first!
             dir.appendPathComponent(self.fileName)
             if let image = UIImage(contentsOfFile: dir.path) {
                 return image
             }else{
                 return nil
             }
         }
         set{ //TODO: 再実装
             let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask).first!
             if let value = newValue{
                 let pngImageData = value.pngData()
                 let counter = RealmPlan().countPlans()-1
                 let pathFileName = dir.appendingPathComponent("XXX\(counter).png")
                 do {
                     try pngImageData!.write(to: pathFileName) //write to file init
                     self.fileName = "XXX\(counter).png" //write to realm
                 } catch {
                     error("ERROR IN WRITE")
                 }
             }
         }
     }
}

class Daydata: Object {
    let eachData = List<EachData>()
    convenience init(eachList:[EachData]){
        self.init()
        for data in eachList{
            self.eachData.append(data)
        }
    }
}

class EachData:Object {
    static func getDate()->Date{
        let calendar = Calendar(identifier: .gregorian)
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())
        let day = calendar.component(.day, from: Date())
        let date = calendar.date(from: DateComponents(year: year, month: month, day: day,hour: 8,minute: 00))
        return date!
    }
    @objc dynamic var timeTo:Double = 0.0 // 所要時間
    @objc dynamic var isLocked:Bool = false //所要時間を編集した値にロック Bool
    @objc dynamic var timeIn:Double = 60*60 // 滞在時間
    @objc dynamic var time:Date = getDate()

    @objc dynamic var name:String = String.empty
    @objc dynamic var address:String = String.empty
    @objc dynamic var detail:String = String.empty

    @objc dynamic var latitude:Double = 0.0
    @objc dynamic var longitude:Double = 0.0
    @objc dynamic var transport:Int = 0

    @objc dynamic var website:String = String.empty

    let imageList = List<ImageData>()

    convenience init(timeTo:Double,
                     isLocked:Bool,
                     timeIn:Double,
                     time:Date,
                     name:String,
                     address:String,
                     detail: String,
                     latitude:Double,
                     longitude:Double,
                     transport:Int,
                     website:String){
        self.init()
        self.timeTo = timeTo
        self.isLocked = isLocked
        self.timeIn = timeIn
        self.time = time
        self.name = name
        self.address = address
        self.detail = detail
        self.latitude = latitude
        self.longitude = longitude
        self.transport = transport
        self.website = website
    }

    dynamic var images:[UIImage?] {
        get{
            var images:[UIImage?] = []
            for image in self.imageList {
                images.append(image.image)
            }
            return images
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["location", "convertedTime", "convertedTimeIn", "images"]
    }
    
    dynamic var location:CLLocationCoordinate2D {
        get{
            return CLLocationCoordinate2DMake(self.latitude, self.longitude)
        }
        set{
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
    dynamic var convertedTime:String { //時間
        get{
            return Settings().timeFormatter().string(from: self.time)
        }
    }
    dynamic var convertedTimeIn:String { //滞在時間
        get{
            return Settings().durationFormatter(time: self.timeIn)
        }
    }
}

//MARK: for other,candidate
class PlaceData:Object {
    @objc dynamic var name:String = String.empty
    @objc dynamic var address:String = String.empty
    @objc dynamic var detail:String = String.empty

    @objc dynamic var latitude:Double = 0.0
    @objc dynamic var longitude:Double = 0.0

    @objc dynamic var website:String = String.empty
    @objc dynamic var category:String = String.empty
    @objc dynamic var isFavorite:Bool = false
    let imageList = List<ImageData>()

    dynamic var location:CLLocationCoordinate2D {
        get{
            return CLLocationCoordinate2DMake(self.latitude, self.longitude)
        }
        set{
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
    dynamic var images:[UIImage?] {
        get{
            var images:[UIImage?] = []
            for image in self.imageList {
                images.append(image.image)
            }
            return images
        }
    }
    override static func ignoredProperties() -> [String] {
        return ["location","images"]
    }
    convenience init(name:String,
                     address:String,
                     detail: String,
                     latitude:Double,
                     longitude:Double,
                     website:String,
                     category:String,
                     isFavorite:Bool){
        self.init()
        self.name = name
        self.address = address
        self.detail = detail
        self.latitude = latitude
        self.longitude = longitude
        self.website = website
        self.category = category
        self.isFavorite = isFavorite
    }
}

//MARK: for candidate
class TextData:Object {
    @objc dynamic var title: String = String.empty
    @objc dynamic var detail: String = String.empty
    convenience init(title:String,detail:String) {
        self.init()
        self.title = title
        self.detail = detail
    }
}

//MARK: for other,candidate
class URLData:Object {
    @objc dynamic var title: String = String.empty
    @objc dynamic var website: String = String.empty
    convenience init(title:String,website:String) {
        self.init()
        self.title = title
        self.website = website
    }
}

//TODO: 再実装
class ImageData:Object {
    @objc dynamic var fileName:String = ""
    dynamic var image:UIImage? {
        get{
            var dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask).first!
            dir.appendPathComponent(self.fileName)
            if let image = UIImage(contentsOfFile: dir.path) {
                return image
            }else{
                ERROR("IMAGE NOT FOUND ERROR")
                return nil
            }
        }
    }

    private func generateImageFile(at index:Int)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateString = dateFormatter.string(from: Date()) + "-" + String(index) + ".png"
        print("file name is set to\(dateString)")
        return dateString
    }

    convenience init(image:UIImage?,at index:Int) {
        self.init()
        if let ima = image {
            let name = generateImageFile(at: index)//error ここがおかしい!!!
            let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask).first!
            let pngImageData = ima.pngData()
            let pathFileName = dir.appendingPathComponent(name)
            do {
                try pngImageData!.write(to: pathFileName) //write to file init
                self.fileName = name //write to realm
            } catch {
                print("ERROR IN WRITE AT INIT OF IMAGEDATA")
            }
        }
    }
    override static func ignoredProperties() -> [String] {
        return ["image"]
    }
}

/*
 extension ImageData: ListDiffable {
 func diffIdentifier() -> NSObjectProtocol {
 return fileName as NSObjectProtocol
 }
 func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
 if self === object { return true }
 guard let object = object as? ImageData else { return false }
 return object.fileName == self.fileName
 }
 }*/

/*
 extension URLData: ListDiffable {
 func diffIdentifier() -> NSObjectProtocol {
 return title as NSObjectProtocol
 }
 func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
 if self === object { return true }
 guard let object = object as? URLData else { return false }
 return object.title == self.title
 }
 }*/
/*
 /*func writeImage(_ num:Int,_ section:Int,_ row:Int,_ index:Int,_ image:UIImage,_ state:ImageState){
 let fileName:String
 let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask).first!
 switch state {
 case .plan:
 fileName = imageFile(num: num, section: section, row: row, index: index,state: state)
 case .place:
 fileName = imageFile(num: 0, section: 0, row: row, index: index,state: state)
 case .candidate:
 fileName = imageFile(num: 0, section: 0, row: row, index: index,state: state)
 }
 let pngImageData = image.pngData()
 let pathFileName = dir.appendingPathComponent(fileName)
 do {
 try pngImageData!.write(to: pathFileName) //write to file
 self.fileName = fileName //write to realm
 } catch {
 print("ERROR IN WRITE AT WRITE IMAGE")
 }
 }*/

 */
//MARK: for candidate
/*class ImageData: Object {
 @objc dynamic var photo: Data? = nil
 dynamic private var _image: UIImage? = nil
 dynamic var image: UIImage? {
 set{
 self._image = newValue
 if let value = newValue {
 self.photo = value.pngData()
 }
 }
 get{
 if let image = self._image {
 return image // if self._image != nil
 }
 if let data = self.photo { // if self.photo != nil
 self._image = UIImage(data: data)
 return self._image
 }
 return nil //if self.photo == nil
 }
 }
 override static func ignoredProperties() -> [String] {
 return ["image", "_image"]
 }
 convenience init(image:UIImage){
 self.init()
 self.image = image
 }
 }*/

