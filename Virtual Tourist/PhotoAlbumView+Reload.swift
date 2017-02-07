//
//  PhotoAlbumView+Reload.swift
//  Virtual Tourist
//
//  Created by Anirudh Ramanan on 06/02/17.
//  Copyright © 2017 Anirudh Ramanan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension PhotoAlbumViewController {
    
    func addReloadButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
    }
    
    func refresh() {
        for photo in fetchedResultsController.fetchedObjects as! [Photos] {
            CoreDataStack.sharedInstance().context.delete(photo)
        }
        
        try! CoreDataStack.sharedInstance().saveContext()
        collectionView.reloadData()
        
        let pageNo: UInt32 = UInt32((totalPages)!)
        FlickrClient.sharedInstance().fetchImagesFromFlickr(pin!, String(pageNo), {
            error in
            
            if error != nil {
                self.showAlertView(error!)
            } else {
                //since the data has been saved in core data, fetch the new results and display them
                self.fetchSavedPhotos()
                self.collectionView.reloadData()
            }
        }, {
            numberofPages in
            self.totalPages = numberofPages
        })
    }
}
