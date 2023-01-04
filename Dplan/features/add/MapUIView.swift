//
//  MapUIView.swift
//  Dplan
//
//  Created by S.Hirano on 2020/03/17.
//  Copyright © 2020 Sola Studio. All rights reserved.
//

import UIKit
import MapKit
import SnapKit
//MARK: IMPROVE add pin 追加

class MapUIView: UIView {
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.overrideUserInterfaceStyle = .light
        return mapView
    }()
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    func loadNib(){
        addSubview(mapView)

        self.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(500)
        })
        mapView.snp.makeConstraints({ (make) -> Void in
            make.left.right.top.bottom.equalToSuperview()
        })
    }

    func setDefaultMap(){
        let dloc = Settings().defaultLoc
        let center = dloc
        let span = MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated:true)
    }
    func setMap(location:CLLocationCoordinate2D ){
        let dloc:CLLocationCoordinate2D! = location
        let center = dloc!
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated:true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = dloc
        mapView.addAnnotation(annotation)
    }
}
