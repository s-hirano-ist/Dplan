//
//  RealmOthers.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/10.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit
import MapKit

class RealmOthers { //MARK: FOR 目的地系統以外の処理
    private let realm = try! Realm()
    func printAll(){
        for p in place(){
            print(p)
        }
    }
    func countPlaces()->Int{
        return place().count
    }
    func countWebsites()->Int{
        return websites().count
    }
    func countTexts()->Int{
        return getText().count
    }

    func getAllDatas()->[PlaceData]{
        var data:[PlaceData] = []
        for loc in place(){
            data.append(loc)
        }
        return data
    }

    func websites()->List<URLData>{
        return realm.objects(Plan.self)[NUMBER].website
    }


    func place()->List<PlaceData>{
        return realm.objects(Plan.self)[NUMBER].place
    }
    func getText()->String{
        return realm.objects(Plan.self)[NUMBER].detail
    }

    func setText(note:String){
        try! realm.write{
            realm.objects(Plan.self)[NUMBER].detail = note
        }
    }

}
//MARK: for images
extension RealmOthers {
    func appendImage(at row:Int,image:UIImage?,at index:Int){
        if let image = image{
            try! self.realm.write{
                data(at: row).imageList.append(ImageData(image: image,at:index))
            }
        }
    }
    func overwriteImage(at row:Int,image:UIImage,at index:Int){
        try! self.realm.write{
            data(at: row).imageList[index] = ImageData(image: image,at:index)
        }
    }

    func removeImage(at row:Int,index:Int){
        print("remove image index\(index),\(row)")
        var dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask).first!
        dir.appendPathComponent(data(at: row).imageList[index].fileName)
        do{
            try FileManager.default.removeItem(atPath: dir.path)
        }catch{
            ERROR("ERROR IN FILE DELETE")
        }
        try! realm.write{
            data(at: row).imageList.remove(at: index)
        }
    }
}

//MARK: FOR URL DATA
extension RealmOthers {
    func isIncluded(string:URL)->Bool{
        for data in websites(){
            if data.website == string.absoluteString {
                return true
            }else{
                continue
            }
        }
        return false
    }
    func includedWebsiteIs(string:URL)->Int{
        for (index,data) in websites().enumerated(){
            if data.website == string.absoluteString {
                return index
            }else{
                continue
            }
        }
        ERROR("ERROR FINDING URL")
        return 0
    }

    func saveWebsite(_ d: URLData){
        try! realm.write{
            websites().append(d)
        }
    }
    func setWebsite(_ d:URLData,at num:Int){
        try! realm.write{
            websites()[num] = d
        }
    }
    func deleteWebsite(at num:Int){
        try! realm.write{
            websites().remove(at: num)
        }
    }
    func getWebsite(at num:Int)-> URLData{
        return websites()[num]
    }
}

//MARK: FOR PLACE DATA
extension RealmOthers {
    func data(at num:Int)->PlaceData{
        return place()[num]
    }
    func savePlace(){
        try! realm.write{
            place().append(PlaceData())
        }
    }
    func deletePlace(at num:Int){
        for (index,_) in data(at: num).imageList.enumerated() {
            removeImage(at: num, index: index)
        }
        try! realm.write{
            place().remove(at: num)
        }
    }

    func setName(at section:Int,name:String){
        try! self.realm.write{
            data(at: section).name = name
        }
    }
    func setAddress(at section:Int,address:String){
        try! self.realm.write{
            data(at: section).address = address
        }
    }
    func setDetail(at section:Int,detail:String){
        try! self.realm.write{
            data(at: section).detail = detail
        }
    }
    func setLocation(at section:Int,location:CLLocationCoordinate2D){
        try! self.realm.write{
            data(at: section).location = location
        }
    }
    func setWebsite(at section:Int,website:String){
        try! self.realm.write{
            data(at: section).website = website
        }
    }
    func setIsFavorite(at section:Int,isFav:Bool){
        try! self.realm.write{
            data(at: section).isFavorite = isFav
        }
    }
}

