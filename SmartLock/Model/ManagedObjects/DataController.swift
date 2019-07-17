//
//  DataController.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 02/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class DataController: NSObject {
    
    var managedObjectContext: NSManagedObjectContext
    
    override  init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: "SmartLock", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.appendingPathComponent("SmartLock.sqlite")
        
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        
    }
    
    func addUser(name: String, surname: String, code: String, isFamily: Bool, isManager: Bool) {
        // create an instance of our managedObjectContext
        let moc = DataController().managedObjectContext
        //deleteAllData(entity: "UserEntity")
        let entityName = "User"
        
        // we set up our entity by selecting the entity and context that we're targeting
        let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: moc) as! User
        
        // check if an entity already exists
        let personFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        // add our data
        do {
            let _ = try moc.fetch(personFetch) as! [User]
            entity.setValue(name, forKey: "name")
            entity.setValue(surname, forKey: "surname")
            entity.setValue(code, forKey: "code")
            entity.setValue(isFamily, forKey: "isFamily")
            entity.setValue(isManager, forKey: "isManager")
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        
        print("DataController - addUser(): Data saved")
        
        // we save our entity
        do {
            try moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
        /*
        switch entityName {
            /*
             * USER DATA
             */
        case "User":
            
            
            /*
             * DEVICE DATA
             */
        case "DeviceData":
            // create an instance of our managedObjectContext
            let moc = DataController().managedObjectContext
            //deleteAllData(entity: "UserEntity")
            print("\nDataController - Devices seeded (yours):")
            for dev in DevicesList.shared.devices {
                // we set up our entity by selecting the entity and context that we're targeting
                let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: moc) as! DeviceData
                
                // check if an entity already exists
                let deviceFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                
                
                // add our data
                do {
                    let _ = try moc.fetch(deviceFetch) as! [DeviceData]
                    entity.setValue(dev.name, forKey: "name")
                    print("- \(dev.name)")
                    entity.setValue(dev.getPlace(), forKey: "place")
                    entity.setValue(dev.getId(), forKey: "id")
                    entity.setValue(dev.isMain, forKey: "isMain")
                    entity.setValue(Double(dev.coords.coordinate.latitude.description), forKey: "coord_x")
                    entity.setValue(Double(dev.coords.coordinate.longitude.description), forKey: "coord_y")
                    entity.setValue(dev.getServerId(), forKey: "serverId")
                    
                    for user in dev.users {
                        let userEntity = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: moc) as! UserData
                        
                        // check if an entity already exists
                        let personFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
                        
                        // add our data
                        do {
                            let _ = try moc.fetch(personFetch) as! [UserData]
                            userEntity.setValue(user.getName(), forKey: "name")
                            userEntity.setValue(user.getSurname(), forKey: "surname")
                            userEntity.setValue(user.getEmail(), forKey: "email")
                            userEntity.setValue(user.getId(), forKey: "id")
                            userEntity.setValue(false, forKey: "isCurrentUser")
                            entity.addToUsers(userEntity)
                        } catch {
                            fatalError("Failed to fetch person: \(error)")
                        }
                    }
                } catch {
                    fatalError("Failed to fetch person: \(error)")
                }
            }
            
            print("")
            print("DataController - seedData(DeviceData): Data saved")
            
            // we save our entity
            do {
                try moc.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            /*
             * TRUSTED DEVICE DATA
             */
        case "TrustedDeviceData":
            // create an instance of our managedObjectContext
            let moc = DataController().managedObjectContext
            //deleteAllData(entity: "UserEntity")
            print("\nDataController - Devices seeded (entrusted):")
            for dev in DevicesList.shared.trustedDevices {
                // we set up our entity by selecting the entity and context that we're targeting
                let entity = NSEntityDescription.insertNewObject(forEntityName: "DeviceData", into: moc) as! DeviceData
                
                // check if an entity already exists
                let deviceFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "DeviceData")
                
                // add our data
                do {
                    // Simple data
                    let _ = try moc.fetch(deviceFetch) as! [DeviceData]
                    entity.setValue(dev.name, forKey: "name")
                    print("- \(dev.name)")
                    entity.setValue(dev.getPlace(), forKey: "place")
                    entity.setValue(dev.getId(), forKey: "id")
                    entity.setValue(dev.isMain, forKey: "isMain")
                    entity.setValue(Double(dev.coords.coordinate.latitude.description), forKey: "coord_x")
                    entity.setValue(Double(dev.coords.coordinate.longitude.description), forKey: "coord_y")
                    entity.setValue(dev.getServerId(), forKey: "serverId")
                    // Trusted users
                    for user in dev.users {
                        let userEntity = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: moc) as! UserData
                        
                        // check if an entity already exists
                        let personFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
                        
                        // add our data
                        do {
                            let _ = try moc.fetch(personFetch) as! [UserData]
                            userEntity.setValue(user.getName(), forKey: "name")
                            userEntity.setValue(user.getSurname(), forKey: "surname")
                            userEntity.setValue(user.getEmail(), forKey: "email")
                            userEntity.setValue(user.getId(), forKey: "id")
                            userEntity.setValue(false, forKey: "isCurrentUser")
                            entity.addToUsers(userEntity)
                        } catch {
                            fatalError("Failed to fetch person: \(error)")
                        }
                    }
                    
                    // Owner
                    let ownerEntity = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: moc) as! UserData
                    
                    // check if an entity already exists
                    let ownerFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
                    
                    // add our data
                    do {
                        let _ = try moc.fetch(ownerFetch) as! [UserData]
                        ownerEntity.setValue(dev.owner.getName(), forKey: "name")
                        ownerEntity.setValue(dev.owner.getSurname(), forKey: "surname")
                        ownerEntity.setValue(dev.owner.getEmail(), forKey: "email")
                        ownerEntity.setValue(dev.owner.getId(), forKey: "id")
                        ownerEntity.setValue(false, forKey: "isCurrentUser")
                        entity.addToOwner(ownerEntity)
                        //let ownerName = entity.owner!.value(forKey: "name").debugDescription
                        //let ownerSurname = entity.owner!.value(forKey: "surname").debugDescription
                        //print("Owner: \(ownerName) \(ownerSurname)")
                    } catch {
                        fatalError("Failed to fetch person: \(error)")
                    }
                } catch {
                    fatalError("Failed to fetch person: \(error)")
                }
                print(entity)
            }
            
            print("DataController - seedData(TrustedDeviceData): Data saved")
            
            // we save our entity
            do {
                try moc.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
        default:
            print("Please insert a valid type of data")
        }
 
    }*/
    
    func fetchData(entityName: String, searchBy fields: [SearchField: AnyObject] = [:], completion: ((_ outcome: Bool?, _ results: [[String: AnyObject]]) -> Void)!) {
        switch entityName {
            /*
             * USER DATA
             */
        case "User":
            let moc = DataController().managedObjectContext
            let personFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            do {
                let fetchedPerson = try moc.fetch(personFetch) as! [User]
                
                var users = [[String: AnyObject]]()
                
                if fetchedPerson.first != nil {
                    for user in fetchedPerson {
                        var found = true
                        if let _ = fields.first {
                            var foundArray = Array(repeating: false, count: fields.count)
                            var j = 0
                            for field in fields {
                                switch field.key {
                                case .name:
                                    if (user.name?.lowercased().contains((field.value as! String).lowercased()))! {
                                        foundArray[j] = true
                                    }
                                case .surname:
                                    if (user.surname?.lowercased().contains((field.value as! String).lowercased()))! {
                                        foundArray[j] = true
                                    }
                                case .nameOrSurname:
                                    if (user.name?.lowercased().contains((field.value as! String).lowercased()))! || (user.surname?.lowercased().contains((field.value as! String).lowercased()))! {
                                        foundArray[j] = true
                                    }
                                case .code:
                                    if (user.code == (field.value as! String)) {
                                   // if (user.code?.contains(field.value as! String))! {
                                        foundArray[j] = true
                                    }
                                case .isFamily:
                                    if (user.isFamily == field.value as! Bool) {
                                        foundArray[j] = true
                                    }
                                case .isManager:
                                    if (user.isManager == field.value as! Bool) {
                                        foundArray[j] = true
                                    }
                                default:
                                    print("Incompatible Search Field")
                                }
                                j += 1
                            }
                            
                            for val in foundArray {
                                if !val {
                                    found = false
                                }
                            }
                        }
                        
                        if found {
                            let name = user.name!
                            let surname = user.surname!
                            let code = user.code!
                            let isFamily = user.isFamily
                            let isManager = user.isManager
                            users.append(["name": name as AnyObject,
                                          "surname" : surname as AnyObject,
                                          "code" : code as AnyObject,
                                          "isFamily" : isFamily as AnyObject,
                                          "isManager" : isManager as AnyObject
                                ])
                        }
                    }
                    completion(true, users)
                } else {
                    // TO FIX
                    //seedData(entityName: entityName)
                }
            } catch {
                fatalError("Failed to fetch person: \(error)")
            }
            
            print("DataController - fetchData(User): Data fetched")
            
            /*
             * DEVICE DATA
             */
        case "Access":
            let moc = DataController().managedObjectContext
            let accessFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            do {
                let fetchedAccesses = try moc.fetch(accessFetch) as! [Access]
                
                var accesses = [[String: AnyObject]]()
                //var i = 0
                
                if fetchedAccesses.first != nil {
                    for acc in fetchedAccesses {
                        var found = true
                        if let _ = fields.first {
                            var foundArray = Array(repeating: false, count: fields.count)
                            var j = 0
                            for field in fields {
                                switch field.key {
                                case .timestampBefore:
                                    if (acc.timestamp! < field.value as! Date) {
                                        foundArray[j] = true
                                    }
                                case .timestampAfter:
                                    if (acc.timestamp! > field.value as! Date) {
                                        foundArray[j] = true
                                    }
                                case .isSuccessful:
                                    if (acc.isSuccessful == field.value as! Bool) {
                                        foundArray[j] = true
                                    }
                                default:
                                    print("Incompatible Search Field")
                                }
                                j += 1
                            }
                            
                            for val in foundArray {
                                if !val {
                                    found = false
                                }
                            }
                        }
                        
                        if found {
                            let timestamp = acc.timestamp!
                            let isSuccessful = acc.isSuccessful
                            accesses.append(["timestamp": timestamp as AnyObject,
                                          "isSuccessful" : isSuccessful as AnyObject
                                ])
                        }
                    }
                    completion(true, accesses)
                } else {
                    // TO FIX
                    //seedData(entityName: entityName)
                }
            } catch {
                fatalError("Failed to fetch person: \(error)")
            }
            
            print("DataController - fetchData(Access): Data fetched")
           
        default:
            print("Please insert a valid type of data")
        }
    }
    /*
    func fetchAllData(completion: ((_ result: Bool?) -> Void)!) {
        var readyOne = false
        var readyTwo = false
        fetchData(entityName: "UserData", completion: {
            completed in
            readyOne = completed!
            completion(readyOne && readyTwo)
        })
        // TO CHANGE:
        if (Network.reachability?.isReachable)! {
            JsonManager.shared.updateUser(email: User.shared.getEmail(), fbKey: User.shared.getId(), firstName: User.shared.getName(), lastName: User.shared.getSurname()) {
                (serverId, error) in
                if let id = serverId {
                    User.shared.setServerId(id)
                }
                self.fetchData(entityName: "DeviceData", completion: {
                    completed in
                    readyTwo = completed!
                    if error != 0 {
                        print("DataController - Server Error from updateUser Call")
                    }
                    completion(readyOne && readyTwo)
                })
                self.fetchData(entityName: "TrustedDeviceData", completion: {
                    completed in
                    //
                })
            }
        } else {
            self.fetchData(entityName: "DeviceData", completion: {
                completed in
                readyTwo = completed!
                completion(readyOne && readyTwo)
            })
            self.fetchData(entityName: "TrustedDeviceData", completion: {
                completed in
                //
            })
        }
        // TrustedDeviceData should be added
    }*/
    
    func deleteData(entityName: String) {
        switch entityName {
            /*
             * USER DATA
             */
        case "User":
            let moc = DataController().managedObjectContext
            
            // check if an entity already exists
            let personFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            // add our data
            do {
                let fetchedPerson = try moc.fetch(personFetch) as! [User]
                //print("User Data2: \(fetchedPerson.first!.bestScore)")
                
                for obj in fetchedPerson {
                    moc.delete(obj)
                }
                print("Users deleted")
            } catch {
                fatalError("Failed to fetch person: \(error)")
            }
            print("DataController - deleteData(User): Data deleted")
            
            // we save our entity
            do {
                try moc.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
            
            /*
             * DEVICE DATA
             */
        case "Access":
            let moc = DataController().managedObjectContext
            
            // check if an entity already exists
            let deviceFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            // add our data
            do {
                let fetchedAccess = try moc.fetch(deviceFetch) as! [Access]
                //print("User Data2: \(fetchedPerson.first!.bestScore)")
                
                for obj in fetchedAccess {
                    moc.delete(obj)
                    
                }
                print("Accesses deleted")
            } catch {
                fatalError("Failed to fetch device: \(error)")
            }
            print("DataController - deleteData(Access): Data deleted")
            
            // we save our entity
            do {
                try moc.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        
        default:
            print("Please insert a valid type of data")
        }
    }
}

enum SearchField {
    case name
    case surname
    case nameOrSurname
    case code
    case isFamily
    case isManager
    case timestampBefore
    case timestampAfter
    case isSuccessful
}
