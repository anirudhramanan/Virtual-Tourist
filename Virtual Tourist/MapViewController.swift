//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Anirudh Ramanan on 05/02/17.
//  Copyright © 2017 Anirudh Ramanan. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var gestureRecognizer: UIGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegate()
    }
    
    @IBAction func addPinToMap(_ gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizer  = gestureRecognizer
        
        /* This is done to receive only one tap and hold gesture at a time. If the state of the gesture has begun, we remove
         the gesture recognizer from the map view, and it is only add back when the annotation gets added on the mapview.
         This way we can make sure that only one pin annotation can be added in a single tap and hold gesture.
         */
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            mapView.removeGestureRecognizer(gestureRecognizer)
        }
        
        let pinPoint: CGPoint = gestureRecognizer.location(in: mapView)
        let locCoord: CLLocationCoordinate2D = mapView.convert(pinPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        self.mapView.addAnnotation(annotation)
    }
}

extension MapViewController : MKMapViewDelegate {
    
    func configureDelegate () {
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        /*
         Since the annotation pin has been added, enable the gesture recognizer to add another pin
         */
        mapView.addGestureRecognizer(gestureRecognizer)
    }
}
