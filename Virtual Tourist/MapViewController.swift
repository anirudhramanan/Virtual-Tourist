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
    var pins = [Pin]()
    var selectedPin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
    }
    
    @IBAction func addPinToMap(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let pinPoint: CGPoint = gestureRecognizer.location(in: mapView)
        let locCoord: CLLocationCoordinate2D = mapView.convert(pinPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        
        // Find out the location name based on the coordinates
        let coordinates = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(coordinates, completionHandler: { (placemark, error) -> Void in
            if error != nil {
                return
            }
            
            if placemark!.count > 0 {
                let pm = placemark![0] as CLPlacemark
                if (pm.locality != nil) && (pm.country != nil) {
                    // Assigning the city and country to the annotation's title
                    annotation.title = "\(pm.locality!), \(pm.country!)"
                } else {
                    annotation.title = "Unknown"
                }
                
                let newPin = Pin(annotation.coordinate.latitude, annotation.coordinate.longitude, annotation.title!)
                self.mapView.addAnnotation(annotation)
                
                FlickrClient.sharedInstance().fetchImagesFromFlickr(newPin, "1", {
                    (error) in
                    
                    if error != nil {
                        self.showAlertView(error!)
                    }
                }, {
                    numberOfPages in
                    newPin.pages = Int32(numberOfPages!)
                    self.pins.append(newPin)
                    self.selectedPin = newPin
                    try? CoreDataStack.sharedInstance().saveContext()
                })
            }
        })
    }
}

extension MapViewController : MKMapViewDelegate {
    
    func configureMap () {
        mapView.delegate = self
        addSavedPinsToMap()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        openPhotoAlbum(view: view)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        openPhotoAlbum(view: view)
    }
    
    func openPhotoAlbum(view: MKAnnotationView) {
        let pinCoordinates: CLLocationCoordinate2D = view.annotation!.coordinate
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumView") as! PhotoAlbumViewController
        controller.coordinates = pinCoordinates
        controller.pin = getSelectedPin(pinCoordinates.latitude, pinCoordinates.longitude)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension MapViewController {
    
    func fetchSavedPins() -> [Pin] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do {
            return try CoreDataStack.sharedInstance().context.fetch(request) as! [Pin]
        } catch {
            return [Pin]()
        }
    }
    
    func addSavedPinsToMap() {
        pins = fetchSavedPins()
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
            annotation.title = pin.title
            mapView.addAnnotation(annotation)
        }
    }
    
    func getSelectedPin(_ lat: Double,_ long: Double) -> Pin {
        for pin in pins {
            if pin.latitude == lat && pin.longitude == long {
                return pin
            }
        }
        return Pin()
    }
}
