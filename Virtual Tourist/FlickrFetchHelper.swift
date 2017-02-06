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
    func fetchImagesFromFlickr(_ pin: Pin,_ page: String,_ errorHandler: @escaping(_ error: String?) -> Void) -> Void {
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=94ff58a573e8a2f6d5bba153a55faee3&lat=\(pin.latitude)&lon=\(pin.longitude)&extras=url_m&format=json&nojsoncallback=1&page=\(page)"
        
        taskForGETMethod(urlString: urlString, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    errorHandler(error)
                }
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                DispatchQueue.main.async {
                    errorHandler("Something Went Wrong!")
                }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
            
            guard let photos = jsonData?["photos"] as? [String: AnyObject], let photo = photos["photo"] as? [[String: AnyObject]] else{
                return
            }
            
            for p in photo {
                guard let photoURLString = p["url_m"] as? String else {
                    continue
                }
                _ = Photos(pin, photoURLString)
            }
            
            do {
                try CoreDataStack.sharedInstance().saveContext()
            } catch {
                print("Error while saving photo object")
            }
        })
    }
    
    func fetchImages(_ photo: Photos,_ completionHandler: @escaping(_ image: UIImage?) -> Void) {
        guard let imageBlob: Data = photo.imageData as Data? else {
            let url = URL(string: photo.url!)
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else {
                        return
                }
                photo.imageData = UIImagePNGRepresentation(image) as NSData?
                do {
                    try CoreDataStack.sharedInstance().saveContext()
                } catch {
                    print("Error saving context")
                }
                DispatchQueue.main.async() {
                    completionHandler(image)
                }
            }
            task.resume()
            return
        }
        
        completionHandler(UIImage(data: imageBlob as Data, scale: 1.0))
    }
}
