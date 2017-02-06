//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Anirudh Ramanan on 05/02/17.
//  Copyright © 2017 Anirudh Ramanan. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {

    init (_ lat: Double,_ long: Double,_ title: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: CoreDataStack.sharedInstance().context)!
        super.init(entity: entity, insertInto: CoreDataStack.sharedInstance().context)
        
        self.latitude = lat
        self.longitude = long
        self.title = title
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
