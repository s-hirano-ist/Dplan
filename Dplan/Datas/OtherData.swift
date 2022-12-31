//
//  OtherData.swift
//  DraPla05
//
//  Created by S.Hirano on 2019/12/30.
//  Copyright © 2019 Sola_studio. All rights reserved.
//

import RealmSwift
import UIKit
import MapKit

class RealmOthers { //MARK: FOR 目的地系統以外の処理
    let realm = try! Realm()
    let s = Settings()
    private func image()->List<ImageData>{
        return realm.objects(Plan.self)[NUMBER].place[0].imageList
    }
    private func URL()->List<URLData>{
        return realm.objects(Plan.self)[NUMBER].URL
    }
    private func place()->List<PlaceData>{
        return realm.objects(Plan.self)[NUMBER].place
    }
}
/*
//MARK: FOR IMAGE DATA in plan
extension RealmOthers {
    func setImage(images: UIImage){
        let data = ImageData()
        data.image = images
        try! self.realm.write{
            image().append(data)
        }
    }
    func getImage()->[UIImage]? {
        var imageData:[UIImage] = []
        for data in image() {
            imageData.append(data.image!)
        }
        return imageData
    }
    func deleteImage(at row:Int) {
        try! realm.write{
            realm.delete(image()[row])
        }
    }
    func countImageData()->Int {
        return image().count
    }
    func addSampleImage() {
        try! realm.write{
            for image in testImages {
                let data = ImageData()
                data.image = image
                self.image().append(data)
            }
        }
    }
}*/

//MARK: FOR URL DATA
extension RealmOthers {
    func setURLData(_ d: URLData){
        try! realm.write{
            URL().append(URLData(value: d))
        }
    }
    func overWritePlan(_ d:URLData,rows:Int){
        try! realm.write{
            URL()[rows] = d
        }
    }
    func isIncluded(string:URL)->Bool{
        for data in URL(){
            if data.URL == string.absoluteString {
                return true
            }else{
                continue
            }
        }
        return false
    }
    func includedURLis(string:URL)->Int{
        var i = 0
        for data in URL(){
            if data.URL == string.absoluteString {
                return i
            }else{
                i += 1
                continue
            }
        }
        print("ERROR FINDING URL")
        return 0
    }
    func deleteURL(at row:Int){
        try! realm.write{
            URL().remove(at: row)
        }
    }
    func deleteAllURL() {
        try! realm.write{
            realm.delete(URL())
        }
    }
    func getURLTitle(at row:Int)->String{
        return  URL()[row].title
    }
    func getURLData(at row:Int)->String{
        if URL()[row].URL == String.empty{
            return "Not entered".localized
        }else{
            return  URL()[row].URL
        }
    }
    func countURLData()->Int {
        return URL().count
    }
}
//MARK: FOR PLACE DATA
extension RealmOthers {
    func setPlaceData(_ d: PlaceData){
        try! realm.write{
            place().append(PlaceData(value:[d]))
        }
    }
    func overWritePlan(_ d:PlaceData,rows:Int){
        try! realm.write{
            place()[rows] = (PlaceData(value:[d]))
        }
    }
    func deletePlace(at row:Int){
        try! realm.write{
            place().remove(at: row)
        }
    }
    func deleteAllPlace(){
        try! realm.write{
            realm.delete(place())
        }
    }
    func getName(at row:Int)->String{
        if place()[row].name == String.empty{
            return "Not entered".localized
        }else{
            return  place()[row].name
        }
    }
    func getAddress(at row:Int)->String{
        if place()[row].address == String.empty{
            return "Not entered".localized
        }else {
            return  place()[row].address
        }
    }
    func getLocation(at row:Int)->CLLocationCoordinate2D{
        let lati = place()[row].latitude
        let long = place()[row].longitude
        return CLLocationCoordinate2DMake(lati,long)
    }
    func countPlaceData()->Int {
        return place().count
    }
}

