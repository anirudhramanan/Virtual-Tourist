//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Anirudh Ramanan on 05/02/17.
//  Copyright © 2017 Anirudh Ramanan. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    var coordinates: CLLocationCoordinate2D!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        loadAnnotation()
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func configureMapView () {
        mapView.delegate = self
        mapView.isScrollEnabled = false
    }
    
    func loadAnnotation () {
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
}
