//
//  FlickrFetchHelper.swift
//  Virtual Tourist
//
//  Created by Anirudh Ramanan on 05/02/17.
//  Copyright © 2017 Anirudh Ramanan. All rights reserved.
//

import Foundation
import MapKit

extension FlickrClient {
    func fetchImagesFromFlickr(_ pin: Pin,_ page: String,_ completionHandler: @escaping(_ data: Data?,_ error: String?) -> Void) -> Void {
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=94ff58a573e8a2f6d5bba153a55faee3&lat=\(pin.latitude)&lon=\(pin.longitude)&extras=url_m&format=json&nojsoncallback=1&page=\(page)"
        
        taskForGETMethod(urlString: urlString, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                DispatchQueue.main.async {
                    completionHandler(nil, "Something Went Wrong!")
                }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
            
            guard let photos = jsonData?["photos"] as? [String: AnyObject], let photo = photos["photo"] as? [[String: AnyObject]] else{
                return
            }
            
            for p in photo {
                guard let photoURLString = p["url_m"] as? String else {
                    print("Error , photoDictionary")
                    continue
                }
                
                let newPhoto = Photos(pin, photoURLString)
                self.fetchImagesFromUrl(newPhoto, completionHandler: {
                    (success, error) in
                    
                    DispatchQueue.main.async {
                        try? CoreDataStack.sharedInstance().saveContext()
                    }
                })
            }
            
            DispatchQueue.main.async {
                completionHandler(data, nil)
            }
        })
    }
    
    func fetchImagesFromUrl(_ photo: Photos!, completionHandler: @escaping(_ success: Bool?,_ error: String?) -> Void) {
        taskForGETMethod(urlString: photo.url!, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(false, error)
                }
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                DispatchQueue.main.async {
                    completionHandler(false, "Something Went Wrong!")
                }
                return
            }
            
            guard let result = data else{
                DispatchQueue.main.async {
                    completionHandler(false, error)
                }
                return
            }
            
            let fileName = (photo.url! as NSString).lastPathComponent
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let pathArray = [dirPath, fileName]
            let fileURL = NSURL.fileURL(withPathComponents: pathArray)!
            print(fileURL)
            
            FileManager.default.createFile(atPath: (fileURL.path), contents: result, attributes: nil)
            
            photo.imagePath = fileURL.path
        
            completionHandler(true, nil)
        })
    }
}
