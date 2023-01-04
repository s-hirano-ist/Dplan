//
//  RealmCandidate.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/10.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import RealmSwift
import MapKit

class RealmCandidate {
    let realm = try! Realm()
    let s = Settings()
    func countData()->Int{
        return realm.objects(Candidate.self).count
    }
    func website()->List<URLData>{
        return realm.objects(Candidate.self)[0].website
    }
    func place()->List<PlaceData>{
        return realm.objects(Candidate.self)[0].place
    }
    func text()->List<TextData>{
        return realm.objects(Candidate.self)[0].text
    }
    func data(at row:Int)->PlaceData{
        return place()[row]
    }
    func countCandidate()->Int{
        return place().count
    }
    func countTextData()->Int {
        return text().count
    }
    func countWebsite()->Int {
        return website().count
    }
    func printAll(){
        print(realm.objects(Candidate.self))
    }
    func addEmptyData(){
        let candidateData = Candidate(textList: [],
                                      URLList: [],
                                      placeList: [])
        try! realm.write{
            realm.add(candidateData)
        }
        print(realm.objects(Candidate.self))
    }
}

//MARK: FOR TEXT DATA in Candidate
extension RealmCandidate {
    func setTextData(_ d: TextData){
        try! realm.write{
            text().append(TextData(value:d))
        }
    }
    func overWriteTextData(_ d:TextData,section:Int){
        try! realm.write{
            text()[section] = (TextData(value:d))
        }
    }
    func getTextTitle(at row:Int)->String{
        return text()[row].title
    }
    func getTextData(at section:Int)->String{
        return text()[section].detail
    }
    func deleteTextData(at section:Int){
        try! realm.write{
            text().remove(at: section)
        }
    }
    func deleteAllTextData() {
        try! realm.write{
            realm.delete(text())
        }
    }
}
//MARK: FOR URL DATA in Candidate
extension RealmCandidate {
    func saveWebsite(_ d: URLData){
        try! realm.write{
            website().append(URLData(value: d))
        }
    }
    func setWebsite(_ d:URLData,at rows:Int){
        try! realm.write{
            website()[rows] = d
        }
    }
    func isIncluded(string:URL)->Bool{
        for data in website(){
            if data.website == string.absoluteString {
                return true
            }else{
                continue
            }
        }
        return false
    }
    func includedWebsiteIs(string:URL)->Int{
        for (index,data) in website().enumerated() {
            if data.website == string.absoluteString {
                return index
            }else{
                continue
            }
        }
        ERROR("ERROR FINDING URL")
        return 0
    }

    func deleteWebsite(at row:Int){
        try! realm.write{
            website().remove(at: row)
        }
    }
    func getWebsite(at row:Int)->URLData{
        return  website()[row]
    }
}
//MARK: FOR PLACE DATA
extension RealmCandidate {
    func getAllDatas()->[PlaceData]{
        var data:[PlaceData] = []
        for loc in place(){
            data.append(loc)
        }
        return data
    }
    
    func saveCandidate(){
        try! realm.write{
            place().append(PlaceData())
        }
    }
    func deleteCandidate(at num:Int){
        for (index,_) in data(at: num).imageList.enumerated() {
            removeImage(at: num, index: index)
        }
        try! realm.write{
            place().remove(at: num)
        }
    }


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
