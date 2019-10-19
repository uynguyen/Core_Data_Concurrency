//
//  PersonManagedObject.swift
//  CoreData-Concurrency
//
//  Created by Nguyen Uy on 6/9/19.
//  Copyright © 2019 Nguyen Uy. All rights reserved.
//

import Foundation
import CoreData

class Person {
    let id: String
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

class PersonManagedObject {
    let serialQueue = DispatchQueue(label: "CoreDataSerialQueue")
    let managedObjectContext: NSManagedObjectContext
    let coreDataStack = PersonCoreDataStack()
    private let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    init?() {
        if let persistentContainer = coreDataStack.persistentContainer {
            self.managedObjectContext = persistentContainer.viewContext
        } else {
            return nil
        }
        
        privateMOC.parent = self.managedObjectContext
    }
    
    func insert(person: Person) {
        self.privateMOC.performAndWait {
            let entity = NSEntityDescription.entity(forEntityName: PersonCoreDataStack.id, in: self.managedObjectContext)!
            let object = NSManagedObject(entity: entity, insertInto: self.privateMOC)
            object.setValue(person.id, forKey: "id")
            object.setValue(person.name, forKey: "name")
            
            self.privateMOC.insert(object)
            print("Insert id succeeded")
            synchronize()
        }
    }
    
    func delete(person: Person) {
        self.privateMOC.performAndWait {
            let fetchQuery = NSFetchRequest<NSFetchRequestResult>(entityName: PersonCoreDataStack.id)
            fetchQuery.predicate = NSPredicate(format: "id = %@", person.id)
            do {
                if let first = try self.privateMOC.fetch(fetchQuery).first as? NSManagedObject {
                    self.privateMOC.delete(first)
                    synchronize()
                    print("Delete id succeeded")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func synchronize() {
        do {
            try self.privateMOC.save() // We call save on the private context, which moves all of the changes into the main queue context without blocking the main queue.
            self.managedObjectContext.performAndWait {
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print("Could not synchonize data. \(error), \(error.localizedDescription)")
                }
            }
        } catch {
            print("Could not synchonize data. \(error), \(error.localizedDescription)")
        }
    }
}
