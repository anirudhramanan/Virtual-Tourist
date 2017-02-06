//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Anirudh Ramanan on 05/02/17.
//  Copyright © 2017 Anirudh Ramanan. All rights reserved.
//

import Foundation

class FlickrClient {
    
    func taskForGETMethod(urlString: String, completionHandler: @escaping (_ result: Data?,_ response: URLResponse?, _ error: String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        let session: URLSession = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil, response, error?.localizedDescription)
                }
            }
            
            DispatchQueue.main.async {
                completionHandler(data, response, nil)
            }
        }
        task.resume()
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}
