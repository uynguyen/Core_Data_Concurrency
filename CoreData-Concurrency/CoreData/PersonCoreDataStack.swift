//
//  PersonCoreDataStack.swift
//  CoreData-Concurrency
//
//  Created by Nguyen Uy on 6/9/19.
//  Copyright © 2019 Nguyen Uy. All rights reserved.
//

import Foundation
import CoreData

class PersonCoreDataStack: CoreDataStack {
    static let id = "PersonModel"
    
    init() {
        super.init(modelIdentify: PersonCoreDataStack.id)
    }
}

