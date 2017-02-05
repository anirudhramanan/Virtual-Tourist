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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureCollectionView()
        loadAnnotation()
        FlickrClient.sharedInstance().fetchImages(coordinates)
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        return cell
    }
}
