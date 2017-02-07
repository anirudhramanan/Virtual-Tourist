    //
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Anirudh Ramanan on 05/02/17.
//  Copyright © 2017 Anirudh Ramanan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var coordinates: CLLocationCoordinate2D!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var pin: Pin?
    var totalPages: Int32?
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        // Create fetch request for photos which match the sent Pin.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
        
        // Create fetched results controller with the new fetch request.
        let fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance().context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureCollectionView()
        addReloadButton()
        fetchSavedPhotos()
        fetchedResultsController.delegate = self
    }
}

extension PhotoAlbumViewController {
    
    func fetchSavedPhotos() {
        try! fetchedResultsController.performFetch()
        totalPages = Int32((pin?.pages)!)
        //if there are no photos saved, query the network
        if fetchedResultsController.fetchedObjects?.count == 0 {
            fetchIfStoreEmpty()
        }
    }
    
    func fetchIfStoreEmpty() {
        let pageNo: UInt32 = UInt32((totalPages)!)
        FlickrClient.sharedInstance().fetchImagesFromFlickr(pin!, String(pageNo), {
            error in
            
            if error != nil {
                self.showAlertView(error!)
            }
        }, {
            numberOfPages in
            self.totalPages = numberOfPages
        })
    }
}
