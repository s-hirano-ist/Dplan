//
//  PlanDataController.swift
//  Dplan
//
//  Created by S.Hirano on 2019/12/18.
//  Copyright © 2019 Sola Studio. All rights reserved.
//

import RealmSwift
import MapKit

//DATA更新以外は検証済 最終検証のみでOK
enum Transport {
    case car //0
    case train //1
    case walk //2
    init(){
        self = Transport.car
    }
}

//FOR main view
class RealmPlan {
    private let realm = try! Realm()
    private let s = Settings()
    func planList()->Results<Plan>{
        return realm.objects(Plan.self)
    }
    func printAllDatas(){
        print(realm.objects(Plan.self))
    }
    func countPlans()->Int{
        return realm.objects(Plan.self).count
    }
    func countDays(at num:Int)->Int{
        if num < countPlans(){
            return realm.objects(Plan.self)[num].dayData.count
        }else{
            print("NO PLANS TO COUNT OUT OF BOUNDS")
            return 0
        }
    }
    func countLastDestination(at num:Int)->Int{
        return realm.objects(Plan.self)[num].dayData.last!.eachData.count
    }
    func countDestination(at num:Int,in section:Int) -> Int{
        return realm.objects(Plan.self)[num].dayData[section].eachData.count
    }
    func plan()->List<Daydata>{
        return realm.objects(Plan.self)[NUMBER].dayData
    }
    func eachPlanData()-> Plan {
        return realm.objects(Plan.self)[NUMBER]
    }
    func data(at section:Int,_ row:Int)->EachData{
        return realm.objects(Plan.self)[NUMBER].dayData[section].eachData[row]
    }
    func calculateIndex(index:Int)->IndexPath{
        var num = index
        for sec in 0..<countDays(at: NUMBER){
            num = num - countDestination(at: NUMBER, in: sec)
            if num <= 0 {
                let row = num + countDestination(at: NUMBER, in: sec)
                let section = sec
                return IndexPath(row: row, section: section)
            }
        }
        ERROR("ERROR IN NIL")
        return IndexPath()
    }
    func calculateIndexPath(at num:Int,indexPath:IndexPath)->Int{
        var counter = 0
        for section in 0..<indexPath.section{
            counter += countDestination(at: num, in: section)
        }
        return counter + indexPath.row
    }
}

//FOR data reload
extension RealmPlan {
    //ok
    func reload(completion: (()->())? = nil){
        print("RELOAD with number\(NUMBER)\n\n")
        polyline = []
        let number = NUMBER

        for i in 0..<countDays(at: number){
            for _ in 0..<countDestination(at: number, in: i){
                polyline.append(MKPolyline())
            }
        }
        //ここだけ引数として取る そうすることによって、変にリロードされない
        self.findRouteAt(number,0,0,completion:completion)
    }

    private func findRouteAt(_ num:Int,_ section:Int,_ row: Int,completion: (()->())? = nil){
        let collection = realm.objects(Plan.self)[num].dayData
        if collection.count == 0 {
            ERROR("FATAL ERROR IN FIND ROUTE")
        }
        if collection[section].eachData.count - 1 == row { //if last row
            self.reloadEventTime(at:num,section)
            if collection.count - 1 == section {
                completion?()
            }else{
                getRoutes(at:num,row, section, 0, section+1, {time in
                    self.findRouteAt(num,section+1, 0,completion: completion)
                })
            }
        }else{
            getRoutes(at:num,row, section, row+1, section, {time in
                self.findRouteAt(num,section, row+1,completion: completion)
            })
        }
    }

    private func getRoutes(at num:Int,_ fromRow: Int,_ fromSection:Int,_ toRow: Int,_ toSection:Int,_ callback: @escaping (Double) -> Void) -> Void {
        if num != NUMBER {
            print("num changed return")
            return
        }

        let requestCoordinate = planP(at: num)[fromSection].eachData[fromRow].location
        let fromCoordinate = planP(at: num)[toSection].eachData[toRow].location

        let fromPlace: MKPlacemark = MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil)
        let toPlace: MKPlacemark = MKPlacemark(coordinate: requestCoordinate, addressDictionary: nil)
        let fromItem: MKMapItem = MKMapItem(placemark: fromPlace)
        let toItem: MKMapItem = MKMapItem(placemark: toPlace)
        let myRequest: MKDirections.Request = MKDirections.Request()

        myRequest.source = fromItem // 出発地のItemをセット.
        myRequest.destination = toItem // 目的地のItemをセット.
        //myRequest.requestsAlternateRoutes = true//複数経路の検索を有効.

        switch planP(at: num)[toSection].eachData[toRow].transport{
        case 0:
            myRequest.transportType = MKDirectionsTransportType.automobile
        case 1:
            myRequest.transportType = MKDirectionsTransportType.transit
        case 2:
            myRequest.transportType = MKDirectionsTransportType.walking
        default:
            myRequest.transportType = MKDirectionsTransportType.walking
            ERROR("ERROR in transport type. Nothing to match.")
        }

        let myDirections: MKDirections = MKDirections(request: myRequest)
        myDirections.calculate() { (response, error) in
            if error != nil || response!.routes.isEmpty {
                ERROR("unable to find route with error\(error!)")
                //NO "TIME TO ZERO" RIGHT NOW
                /*if self.plan()[toSection].eachData[toRow].isLocked == false {
                    try! self.realm.write {
                        self.plan()[fromSection].eachData[fromRow].timeTo = 0
                    }
                }else {
                    DEBUG("LOCKED TIME DATA")
                }*/
                //polyline.append(MKPolyline())
                polyline[self.calculateIndexPath(at: num,indexPath: IndexPath(row: fromRow, section: fromSection))] = MKPolyline()
                callback(0)
                return
            }// 以下 else節
            let route: MKRoute = response!.routes[0] as MKRoute
            //polyline.append(route.polyline)

            if polyline.count > self.calculateIndexPath(at:num, indexPath: IndexPath(row: fromRow, section: fromSection)){
                polyline[self.calculateIndexPath(at:num, indexPath: IndexPath(row: fromRow, section: fromSection))] = route.polyline
            }else{
                print("fatal error in bounds exception \n\n")
            }
            if self.planP(at: num)[toSection].eachData[toRow].isLocked == false {
                try! self.realm.write {
                    self.planP(at: num)[toSection].eachData[toRow].timeTo = route.expectedTravelTime
                }
            }else {
                DEBUG("LOCKED TIME DATA")
            }
            //print(self.data(at: fromSection, fromRow).name)
            //DEBUG("distance" + route.distance + "description" + route.description)
            callback(route.expectedTravelTime)
        }
    }
    private func planP(at num:Int)->List<Daydata>{
        return realm.objects(Plan.self)[num].dayData
    }
    private func dataP(at num:Int,_ section:Int,_ row:Int)->EachData{
        return realm.objects(Plan.self)[num].dayData[section].eachData[row]
    }
    private func setTimeP(at num:Int,_ section:Int,_ row:Int,time:Date){
        try! self.realm.write{
            dataP(at:num, section, row).time = time
        }
    }

    private func reloadEventTime(at num:Int,_ section: Int){
        if section != 0 {
            let time = dataP(at:num, section-1, countDestination(at: num, in: section-1)-1).time
            let calendar = Calendar(identifier: .gregorian)
            let year = calendar.component(.year, from: time)
            let month = calendar.component(.month, from: time)
            let day = calendar.component(.day, from: time) + 1
            let hour = calendar.component(.hour, from: dataP(at:num, section, 0).time)
            let minute = calendar.component(.minute, from: dataP(at:num, section, 0).time)

            let date = calendar.date(from: DateComponents(year: year, month: month, day: day,hour: hour,minute: minute))

            setTimeP(at:num, section, 0, time: date!)
        }
        for element in 1 ..< plan()[section].eachData.count {
            var dateToAdd = planP(at:num)[section].eachData[element-1].time
            let timeTakenTo = planP(at:num)[section].eachData[element].timeTo
            let timeTakenIn = planP(at:num)[section].eachData[element-1].timeIn

            let minTo: Int = Int(timeTakenTo)/60 % 60
            let hourTo: Int = (Int(timeTakenTo)/60-minTo)/60

            let compsTo = DateComponents(hour: hourTo, minute: minTo)
            let minIn: Int = Int(timeTakenIn)/60 % 60
            let hourIn: Int = (Int(timeTakenIn)/60-minIn)/60
            var compsIn = DateComponents(hour: hourIn, minute: minIn)

            if timeTakenIn == 23*60*60+50*60 {
                compsIn = DateComponents(hour: 0, minute: 0)
            }
            dateToAdd = Calendar.current.date(byAdding: compsTo, to: dateToAdd)!
            dateToAdd = Calendar.current.date(byAdding: compsIn, to: dateToAdd)!
            try! realm.write {
                self.planP(at:num)[section].eachData[element].time = dateToAdd
            }
        }
    }
}
//for getters
extension RealmPlan {
    func getTitle(at num:Int)->String {
        if realm.objects(Plan.self)[num].title == String.empty{
            return "No Title".localized
        }
        return realm.objects(Plan.self)[num].title
    }
    func getDatePeriod(at num:Int)->String{
        let fromDate = realm.objects(Plan.self)[num].dayData[0].eachData[0].time
        let addDay = countDays(at:num) - 1
        let oneDay = DateComponents(day: addDay ,hour: 0, minute: 0)
        let toDate = Calendar.current.date(byAdding: oneDay, to: fromDate)!
        if addDay == 0{
            return s.dateFormatter().string(from: fromDate)
        }
        else{
            return s.dateFormatter().string(from: fromDate) + "〜".localized + s.dateFormatter().string(from: toDate)
        }
    }
    func getTitleImage(at num:Int)->UIImage?{
        return realm.objects(Plan.self)[num].image
    }
    func getisFavorite(at num:Int)->Bool{
        return realm.objects(Plan.self)[num].isFavorite
    }

    //for header
    func getDate(at section:Int)->String{
        let fromDate = data(at:0, 0).time
        let addDay = DateComponents(day: section,hour: 0, minute: 0)
        let toDate = Calendar.current.date(byAdding: addDay, to: fromDate)!
        return s.dateFormatter().string(from: toDate)
    }
}

// set methods of eachData
extension RealmPlan {

    func setTitle(at num:Int, to name:String){
        try! self.realm.write{
            self.realm.objects(Plan.self)[num].title = name
        }
    }
    func setTitleImage(at num:Int,to image:UIImage?){
        if let image = image {
            try! self.realm.write{
                self.realm.objects(Plan.self)[num].image = image
            }
        }
    }
    func setIsFavorite(at num:Int,to bool:Bool){
        try! self.realm.write{
            self.realm.objects(Plan.self)[num].isFavorite = bool
        }
    }
    func setStartDate(at num:Int,to date:Date){
        try! self.realm.write{
            self.realm.objects(Plan.self)[num].dayData[0].eachData[0].time = date
        }
    }

    func setTimeToWithIsLocked(at section:Int,_ row:Int,withTime timeTo:Double,isLocked:Bool,transport:Int){
        try! self.realm.write{
            data(at: section, row).timeTo = timeTo
            data(at: section, row).isLocked = isLocked
            data(at: section, row).transport = transport
        }
    }

    func setTimeIn(at section:Int,_ row:Int,timeIn:Double){
        try! self.realm.write{
            data(at: section, row).timeIn = timeIn
        }
    }
    func setTime(at section:Int,_ row:Int,time:Date){
        try! self.realm.write{
            data(at: section, row).time = time
        }
    }
    func setName(at section:Int,_ row:Int,name:String){
        try! self.realm.write{
            data(at: section, row).name = name
        }
    }

    func setAddress(at section:Int,_ row:Int,address:String){
        try! self.realm.write{
            data(at: section, row).address = address
        }
    }
    func setDetail(at section:Int,_ row:Int,detail:String){
        try! self.realm.write{
            data(at: section, row).detail = detail
        }
    }
    func setLocation(at section:Int,_ row:Int,location:CLLocationCoordinate2D){
        try! self.realm.write{
            data(at: section, row).location = location
        }
    }
    func setTransport(at section:Int,_ row:Int,transport:Int){
        try! self.realm.write{
            data(at: section, row).transport = transport
        }
    }
    func setWebsite(at section:Int,_ row:Int,website:String){
        try! self.realm.write{
            data(at: section, row).website = website
        }
    }
    
    func appendImage(at section:Int,_ row:Int,image:UIImage?,at index:Int){
        if let image = image{
            try! self.realm.write{
                data(at: section, row).imageList.append(ImageData(image: image,at:index))
            }
        }
    }
    func overwriteImage(at section:Int,_ row:Int,image:UIImage,at index:Int){
        try! self.realm.write{
            data(at: section,row).imageList[index] = ImageData(image: image,at:index)
        }
    }

}

// save overwrite,delete,move methods
extension RealmPlan {
    func addSample(){
        let d = EachData()
        let da = Daydata(eachList: [d])
        let planData = Plan(title: "Sample Plan".localized,
                            detail: String.empty,
                            titleImage: R.image.vertImage()!,
                            isFavorite: false,
                            planList: [da],
                            URLList: [],
                            placeList: [])
        try! realm.write{
            realm.add(planData)
        }
    }

    func saveNewPlan(){
        try! realm.write{
            realm.add(Plan(title: String.empty,
                           detail: String.empty,
                           titleImage: nil,
                           isFavorite: false,
                           planList: [Daydata(eachList: [EachData()])],
                           URLList: [],
                           placeList: []))
        }
    }
    func saveNewDay(){
        try! realm.write{
            plan().append(Daydata(eachList: [EachData()]))
        }
    }
    func saveExistDay(){
        try! realm.write{
            plan().last!.eachData.append(EachData())
        }
    }

    func setNewPlan(data:Plan){
        try! realm.write{
            realm.add(data)
        }
    }

    func deletePlan(at num:Int){
        for section in 0..<countDays(at: num){
            for row in 0..<countDestination(at: num, in: section){
                deleteAllImage(at: section, row)
            }
        }
        try! realm.write{
            realm.delete(realm.objects(Plan.self)[num])
        }
    }
    func deleteSection(at section:Int){
        for row in 0 ..< countDestination(at: NUMBER, in: section){
            deleteAllImage(at: section, row)
        }
        try! realm.write{
            realm.delete(plan()[section])
        }
    }
    func deleteRow(at section:Int,_ row:Int){
        deleteAllImage(at: section, row)
        try! realm.write{
            plan()[section].eachData.remove(at: row)
        }
    }
    func deleteAllImage(at section:Int,_ row:Int){
        for i in data(at: section, row).imageList{
            print("remove image\(section),\(row)")
            var dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask).first!
            dir.appendPathComponent(i.fileName)
            do{
                try FileManager.default.removeItem(atPath: dir.path)
            }catch{
                ERROR("ERROR IN FILE DELETE")
            }
        }
    }
    func removeImage(at section:Int,_ row:Int,index:Int){
        print("remove image index\(index),\(section),\(row)")
        var dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask).first!
        dir.appendPathComponent(data(at: section, row).imageList[index].fileName)
        do{
            try FileManager.default.removeItem(atPath: dir.path)
        }catch{
            ERROR("ERROR IN FILE DELETE")
        }
        try! realm.write{
            data(at: section, row).imageList.remove(at: index)
        }
    }
    func moveTo(source:IndexPath ,dest:IndexPath){
        let data = plan()[source.section].eachData[source.row]
        try! realm.write{
            plan()[source.section].eachData.remove(at: source.row)
            plan()[dest.section].eachData.insert(data, at: dest.row)
        }
    }
}
