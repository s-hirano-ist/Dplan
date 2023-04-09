//
//  ListView.swift
//  Dplan
//
//  Created by Soraki Hirano on 2023/01/04.
//  Copyright © 2023 Sola Studio. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit
import Material

class ListViewController: UIViewController {
    
    var topBarView = TopBarView()
    lazy var collectionView :UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 40)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(),
                           viewController: self,
                           workingRangeSize: 2)
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = R.color.mainWhite()!
        setConsraints()
    }
    
    func setConsraints(){
        view.addSubview(topBarView)
        view.addSubview(collectionView)
        
        topBarView.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
        })
        collectionView.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(topBarView.snp.bottom)
            make.right.left.equalToSuperview()
            make.bottom.equalToSuperview()
        })
    }
}
