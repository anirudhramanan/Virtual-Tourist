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

        // Sort the fetch request by title, ascending.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imagePath", ascending: true)]
        
        // Create fetched results controller with the new fetch request.
        let fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance().context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        fetchSavedPhotos()
        configureCollectionView()
        loadAnnotation()
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
        
        let photo = fetchedResultsController.object(at: indexPath) as! Photos
        
        cell.albumImage.image = getImageFromPath(photo.imagePath!)
        
        return cell
    }
}

extension PhotoAlbumViewController {
    
    func fetchSavedPhotos() {
        try? fetchedResultsController.performFetch()
    }
    
    func getImageFromPath(_ filePath: String) -> UIImage? {
        let fileName = (filePath as NSString).lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathArray = [dirPath,fileName]
        let fileURL = NSURL.fileURL(withPathComponents: pathArray)
        
        return UIImage(contentsOfFile: (fileURL!.path))
    }
}
