//
//  BannerView.swift
//  Dplan
//
//  Created by Soraki Hirano on 2023/01/04.
//  Copyright © 2023 Sola Studio. All rights reserved.
//

import UIKit

class BannerView: UIView {
    
    let adsBannerViewHeight = 60
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .gray
        self.addSubview(dummyTextForAds)
        self.snp.makeConstraints({(make) -> Void in
            make.height.equalTo(UserDefaults.standard.bool(forKey: "premiumFeatures") ? 0 : adsBannerViewHeight)
        })
        dummyTextForAds.snp.makeConstraints({(make) -> Void in
            make.top.bottom.left.right.equalToSuperview()
        })
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var dummyTextForAds:UILabel = {
        let label = UILabel()
        label.text = "dummy banner for Ads"
        label.textAlignment = .center
        return label
    }()
}


//FIXME: is subscribed or not
//import GoogleMobileAds


//    func addBannerViewToView() {
//        adView = GADBannerView(adSize: kGADAdSizeBanner)
//        adView.adUnitID = "ca-app-pub-4476878961223776/7612061551"//real
//        //adView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //test
//        adView.rootViewController = self
//        adView.load(GADRequest())
//        bannerView.addSubview(adView)
//        adView.snp.makeConstraints({ (make) -> Void in
//            make.centerX.equalToSuperview()
//        })
//    }

//    var adView:GADBannerView!
