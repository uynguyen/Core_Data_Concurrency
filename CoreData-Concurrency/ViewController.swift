//
//  ViewController.swift
//  CoreData-Concurrency
//
//  Created by Nguyen Uy on 6/9/19.
//  Copyright © 2019 Nguyen Uy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let managedContext = PersonManagedObject()
    let person = Person(id: UUID().uuidString, name: "Uy Nguyen")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.doSomething()
    }
    
    func doSomething() {
        self.managedContext?.insert(person: self.person)
        self.managedContext?.delete(person: self.person)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1, execute: {
            self.doSomething()
        })
    }
}

