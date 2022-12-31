//
//  SearchDestinationView.swift
//  DraPla05
//
//  Created by S.Hirano on 2020/03/02.
//  Copyright © 2020 Sola_studio. All rights reserved.
//

import UIKit
import MapKit

protocol SearchDestinationViewDelegate {
    func setLocation(location:CLLocationCoordinate2D)->Void
    func setNameAndAddress(name:String,address:String)->Void
}

class SearchDestinationView: UITableViewController {
    var delegate:SearchDestinationViewDelegate?

    var searchCell:UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    var searchBar:UISearchBar!
    var searchCompleter:MKLocalSearchCompleter!
}

extension SearchDestinationView{
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCompleter.results.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 40
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        searchCell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        let completion = searchCompleter.results[indexPath.row]
        searchCell.textLabel?.text = completion.title
        searchCell.detailTextLabel?.text = completion.subtitle
        return searchCell
    }
    
    //MARK: IMRPOVE 近くを探す 等 除外するべき選択肢多数．必要に応じて要改良．
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let geocoder = CLGeocoder()

        var ableToFind = true
        geocoder.geocodeAddressString(
            searchCompleter.results[indexPath.row].subtitle,
            completionHandler: {(placemarks, error) in
                if error == nil {
                    for place in placemarks! {
                        //MARK: 何個もplacemarkあった場合はどうする?
                        print("placemark number")
                        print(place)
                        self.delegate?.setLocation(location:place.location!.coordinate)
                    }
                }else{
                    ERROR("unable to search by address")
                    geocoder.geocodeAddressString(
                        self.searchCompleter.results[indexPath.row].title,
                        completionHandler: {
                            (placemarks, error) in
                            if error == nil {
                                for place in placemarks! {
                                    print("placemark number")
                                    print(place)
                                    self.delegate?.setLocation(location:place.location!.coordinate)
                                }
                            }else{
                                ERROR("unable to search by name as well")
                                ableToFind = false
                            }
                    })
                }
                if let parent = self.parent as? PlanLocationView {
                    parent.detailView.titleField.text = self.searchCompleter.results[indexPath.row].title
                    parent.detailView.addressField.text = self.searchCompleter.results[indexPath.row].subtitle
                    if !ableToFind {
                        parent.detailView.addressField.textColor = R.color.subRed()!
                    }
                }
                if let parent = self.parent as? PlaceLocationView {
                    parent.detailView.titleField.text = self.searchCompleter.results[indexPath.row].title
                    parent.detailView.addressField.text = self.searchCompleter.results[indexPath.row].subtitle
                    if !ableToFind {
                        parent.detailView.addressField.textColor = R.color.subRed()!
                    }
                }
                if let parent = self.parent as? CandidateLocationView {
                    parent.detailView.titleField.text = self.searchCompleter.results[indexPath.row].title
                    parent.detailView.addressField.text = self.searchCompleter.results[indexPath.row].subtitle
                    if !ableToFind {
                        parent.detailView.addressField.textColor = R.color.subRed()!
                    }
                }
                self.delegate?.setNameAndAddress(name: self.searchCompleter.results[indexPath.row].title,
                                                 address: self.searchCompleter.results[indexPath.row].subtitle)
        })
        searchBar.text = String.empty
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searchCompleter.queryFragment = String.empty

    }
}
