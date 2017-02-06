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
        
        let pageNo: UInt32 = UInt32((pin?.pages)!) > 200 ? 200 : UInt32((pin?.pages)!)
        FlickrClient.sharedInstance().fetchImagesFromFlickr(pin!, String(arc4random_uniform(pageNo) + 1), {
            error in
            
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.actionSheet)
                alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                //since the data has been saved in core data, fetch the new results and display them
                self.fetchSavedPhotos()
            }
        })
    }
}
