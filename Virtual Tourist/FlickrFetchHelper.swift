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
    func fetchImages(_ coordinates: CLLocationCoordinate2D) -> Void {
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=94ff58a573e8a2f6d5bba153a55faee3&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&extras=url_m&format=json&nojsoncallback=1"
        
        taskForGETMethod(urlString: urlString, completionHandler: {
            (data, error) in
            
            let jsonData = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
            
            guard let stat = jsonData?["stat"] as? String else{
                return
            }
            
            if stat == "ok" {
                guard let photos = jsonData?["photos"] as? [String: AnyObject], let photo = photos["photo"] as? [[String: AnyObject]] else{
                    return
                }
                
                var urls: [[String]]!
            }
        })
    }
}
