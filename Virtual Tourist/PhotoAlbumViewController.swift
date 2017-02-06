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
        //if there are no photos saved, query the network
        if fetchedResultsController.fetchedObjects?.count == 0 {
            fetchIfStoreEmpty()
        }
    }
    
    func fetchIfStoreEmpty() {
        let pageNo: UInt32 = UInt32((pin?.pages)!) > 200 ? 200 : UInt32((pin?.pages)!)
        FlickrClient.sharedInstance().fetchImagesFromFlickr(pin!, String(arc4random_uniform(pageNo) + 1), {
            error in
            
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.actionSheet)
                alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else{
                self.fetchSavedPhotos()
            }
        })
    }
}
