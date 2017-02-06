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
    var photos: [Photos]?
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        // Create fetch request for photos which match the sent Pin.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
        
        // Create fetched results controller with the new fetch request.
        let fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance().context, sectionNameKeyPath: nil, cacheName: nil)
        
        self.photos = try? CoreDataStack.sharedInstance().context.fetch(fetchRequest) as! [Photos]
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureCollectionView()
        loadAnnotation()
        
        fetchSavedPhotos()
        fetchIfStoreEmpty()
        fetchedResultsController.delegate = self
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

extension PhotoAlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func configureCollectionView () {
        collectionView.delegate = self
        collectionView.dataSource = self
        configureFlowLayout()
    }
    
    private func configureFlowLayout() {
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        let photos = fetchedResultsController.object(at: indexPath) as! Photos
        FlickrClient.sharedInstance().fetchImages(photos, {
            image in
            cell.albumImage.image = image
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photos = fetchedResultsController.object(at: indexPath) as! Photos
        CoreDataStack.sharedInstance().context.delete(photos)
        do {
            try CoreDataStack.sharedInstance().saveContext()
        } catch {
            print("Error saving context")
        }
        fetchSavedPhotos()
    }
}

extension PhotoAlbumViewController {
    
    func fetchSavedPhotos() {
        try? fetchedResultsController.performFetch()
    }
    
    func fetchIfStoreEmpty() {
        if photos?.count == 0 {
            let pageNo: UInt32 = UInt32((pin?.pages)!) > 200 ? 200 : UInt32((pin?.pages)!)
            FlickrClient.sharedInstance().fetchImagesFromFlickr(pin!, String(arc4random_uniform(pageNo) + 1), {
                error in
                
            })
        }
    }
}
