//
//  ListView.swift
//  Dplan
//
//  Created by Soraki Hirano on 2023/01/04.
//  Copyright © 2023 Sola Studio. All rights reserved.
//

import UIKit

class ListView: UIViewController {
    lazy var collectionView :UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 40)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        
    }
}
