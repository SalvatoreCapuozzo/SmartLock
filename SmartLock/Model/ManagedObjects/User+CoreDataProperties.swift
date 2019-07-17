//
//  User+CoreDataProperties.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 02/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var surname: String?
    @NSManaged public var code: String?
    @NSManaged public var isFamily: Bool
    @NSManaged public var isManager: Bool

}
