//
//  ObjectsForIGListKit.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/31.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import Foundation
import IGListKit

class SectionState: NSObject {
    enum state {
        case plan
        case place
        case candidate
        init() {
            self = .plan
        }
    }
    var data:state!
    override init() {
        data = .plan
    }
    init(data:state) {
        self.data = data
    }
}
extension SectionState: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}

class Images: NSObject {
    var imageArray:[ImageData?]
    override init(){
        self.imageArray = []
    }
}
extension Images: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}
