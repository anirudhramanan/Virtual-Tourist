//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Anirudh Ramanan on 05/02/17.
//  Copyright © 2017 Anirudh Ramanan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var gestureRecognizer: UIGestureRecognizer!
    var pins = [Pin]()
    var selectedPin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegate()
        addSavedPinsToMap()
    }
    
    @IBAction func addPinToMap(_ gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizer  = gestureRecognizer
        
        /* This is done to receive only one tap and hold gesture at a time. If the state of the gesture has begun, we remove
         the gesture recognizer from the map view, and it is only add back when the annotation gets added on the mapview.
         This way we can make sure that only one pin annotation can be added in a single tap and hold gesture.
         */
        
        if gestureRecognizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let pinPoint: CGPoint = gestureRecognizer.location(in: mapView)
        let locCoord: CLLocationCoordinate2D = mapView.convert(pinPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        self.mapView.addAnnotation(annotation)
        
        let newPin = Pin(annotation.coordinate.latitude, annotation.coordinate.longitude)
        pins.append(newPin)
        selectedPin = newPin
        try? CoreDataStack.sharedInstance().saveContext()
        
        FlickrClient.sharedInstance().fetchImagesFromFlickr(newPin, "1", {
            (data, error) in

        })
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
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pinCoordinates: CLLocationCoordinate2D = view.annotation!.coordinate
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumView") as! PhotoAlbumViewController
        controller.coordinates = pinCoordinates
        controller.pin = selectedPin
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension MapViewController {
    
    func fetchSavedPins() -> [Pin] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do {
            return try CoreDataStack.sharedInstance().context.fetch(request) as! [Pin]
        }catch {
            return [Pin]()
        }
    }
    
    func addSavedPinsToMap() {
        pins = fetchSavedPins()
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
            mapView.addAnnotation(annotation)
        }
    }
}
