//
//  Photos+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Anirudh Ramanan on 05/02/17.
//  Copyright © 2017 Anirudh Ramanan. All rights reserved.
//

import Foundation
import CoreData

@objc(Photos)
public class Photos: NSManagedObject {
    
    init (_ pin: Pin,_ url: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Photos", in: CoreDataStack.sharedInstance().context)!
        super.init(entity: entity, insertInto: CoreDataStack.sharedInstance().context)
        
        self.pin = pin
        self.url = url
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
