//
//  TableCardCollection.swift
//  DraPla05
//
//  Created by S.Hirano on 2019/12/19.
//  Copyright © 2019 Sola_studio. All rights reserved.
//


import CollectionKit
import UIKit
import Eureka

class NoteView: FormViewController { //MARK: for 候補地 tableView用．
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = self.view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setForm()
    }
    func setForm(){
        form +++
            Section()
            <<<
            TextAreaRow("notes") {
                $0.value = "AKDSA"
                $0.textAreaMode = .readOnly
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 200)
        }
    }
    func addNoteToForm(){
        let section = form.last!
        section <<<
            TextAreaRow("notes") {
                $0.value = "AKDSA"
                $0.textAreaMode = .readOnly
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 200)
        }
    }
}
