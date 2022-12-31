//
//  ShowMapView.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/22.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import UIKit
import MapKit

//MARK: for want to go IMPROVE VIEW

class ShowMapView: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    private let s = Settings()

    //前画面から引き継ぐデータ
    var locData:[CLLocationCoordinate2D] = []
    var nameData:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if locData.count == 0 {
            //MARK: IMPROVE ここの値を変更
            locData.append(RealmPlan().data(at:0,0).location)
            locData.append(RealmPlan().data(at:0,1).location)
            nameData.append("First Loc")
            nameData.append("Second Loc")
        }
        reloadMap()
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ShowMapView:CLLocationManagerDelegate,MKMapViewDelegate,MKLocalSearchCompleterDelegate{

func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let route: MKPolyline = overlay as! MKPolyline
        let routeRenderer: MKPolylineRenderer = MKPolylineRenderer(polyline: route)
        routeRenderer.lineWidth = 8.0 // ルートの線の太さ.
        routeRenderer.strokeColor = R.color.mainCyan()! // ルートの線の色.
        return routeRenderer
    }

    //MARK: IMPROVE 倍率等はmainMapViewを参考に
    private func setMap(){
        mapView.delegate = self
        let ceterOfMap = s.defaultLoc // 初期値 東京駅(仮)
        let spanOfMap: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)//(仮)
        let regionOfMap = MKCoordinateRegion(center: ceterOfMap, span: spanOfMap)
        mapView.setCenter(ceterOfMap, animated: true)// mapViewに中心をセットする.
        mapView.setRegion(regionOfMap, animated:true)
    }

    private func reloadMap(){
        mapView.removeOverlays(mapView.overlays)
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
        setMap()
        for row in 0 ..< locData.count {
            let pin: MKPointAnnotation = MKPointAnnotation()
            pin.coordinate = locData[row]
            pin.title = nameData[row]
            self.mapView.addAnnotation(pin)
        }
    }
}
