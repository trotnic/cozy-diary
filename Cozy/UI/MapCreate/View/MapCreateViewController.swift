//
//  MapCreateViewController.swift
//  Cozy
//
//  Created by Uladzislau Volchyk on 8/24/20.
//  Copyright © 2020 Uladzislau Volchyk. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class MapCreateViewController: BaseViewController, MKMapViewDelegate {

    let viewModel: MapCreateViewModelType
    let locationManager = CLLocationManager()
    
    private let disposeBag = DisposeBag()
    
    var resultSearchController: UISearchController?
    
    init(viewModel: MapCreateViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    

        
        
        view.addSubview(mapView)
        
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let tapReco = UITapGestureRecognizer()
        tapReco.rx.event
            .subscribe(onNext: { [unowned self] (recognizer) in
                let location = recognizer.location(in:self.mapView)
                let coordinates = self.mapView.convert(location, toCoordinateFrom: self.mapView)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                self.mapView.addAnnotation(annotation)
        }).disposed(by: disposeBag)
        
        mapView.addGestureRecognizer(tapReco)
        
        
        setupLocationManager()
        setupSearchBar()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func setupSearchBar() {
        let locationSearchTable = LocationSearchTable(style: .insetGrouped)
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        
        let item = UINavigationItem()
        item.searchController = resultSearchController
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        let bar = UINavigationBar()
        bar.isTranslucent = false
        bar.delegate = self
        
        view.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
}

extension MapCreateViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
}

extension MapCreateViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}




// MARK: Locations Search

class LocationSearchTable : UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
    }
}

extension LocationSearchTable: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
