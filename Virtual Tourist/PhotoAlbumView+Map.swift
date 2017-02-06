//
//  PhotoAlbumView+Map.swift
//  Virtual Tourist
//
//  Created by Anirudh Ramanan on 06/02/17.
//  Copyright © 2017 Anirudh Ramanan. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func configureMapView () {
        mapView.delegate = self
        mapView.isScrollEnabled = false
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
}
