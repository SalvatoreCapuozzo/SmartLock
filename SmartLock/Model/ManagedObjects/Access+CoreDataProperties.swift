//
//  Access+CoreDataProperties.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 20/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//
//

import Foundation
import CoreData


extension Access {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Access> {
        return NSFetchRequest<Access>(entityName: "Access")
    }

    @NSManaged public var isSuccessful: Bool
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var user: User?

}
