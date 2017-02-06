//
//  PhotoAlbumView+Collection.swift
//  Virtual Tourist
//
//  Created by Anirudh Ramanan on 06/02/17.
//  Copyright © 2017 Anirudh Ramanan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

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
        
        if  photos.url != nil {
            FlickrClient.sharedInstance().fetchImages(photos, {
                image in
                cell.albumImage.image = image
            })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath) as! Photos
        CoreDataStack.sharedInstance().context.delete(photo)
        try? CoreDataStack.sharedInstance().saveContext()
        fetchSavedPhotos()
        collectionView.reloadData()
    }
}
