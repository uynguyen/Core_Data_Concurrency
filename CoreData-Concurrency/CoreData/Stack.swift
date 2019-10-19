//
//  Stack.swift
//  CoreData-Concurrency
//
//  Created by Nguyen Uy on 6/9/19.
//  Copyright © 2019 Nguyen Uy. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    private let modelIdentify: String
    private var managedObjectModel: NSManagedObjectModel?
    private var fileURL: URL? {
        return Bundle(for: type(of: self)).url(forResource: self.modelIdentify, withExtension: "momd")
    }
    
    init(modelIdentify: String) {
        self.modelIdentify = modelIdentify
        if self.fileURL != nil {
            self.managedObjectModel = NSManagedObjectModel(contentsOf: self.fileURL!)
        } else {
            
        }
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    lazy var persistentContainer: NSPersistentContainer? = {
        if self.managedObjectModel != nil {
            let container = NSPersistentContainer(name: self.modelIdentify, managedObjectModel: managedObjectModel!)
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        } else {
            return nil
        }
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        if self.managedObjectModel != nil {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel!)
            let url = self.applicationDocumentsDirectory.appendingPathComponent("\(self.modelIdentify).sqlite")
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            } catch {
                
            }
            return coordinator
        } else {
            return nil
        }
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        if self.persistentStoreCoordinator != nil {
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
            return managedObjectContext
        } else {
            return nil
        }
    }()
}
