//
//  Note.swift
//  EasyNotes
//
//  Created by Yogi Priyo Prayogo on 06/06/21.
//  Copyright © 2021 Yogi Priyo Prayogo. All rights reserved.
//

import CoreData

class EasyNote: NSManagedObject {
    
    // MARK: - Note: still unusable due to time limit
    var title: String?
    var content: String?
    
    convenience init(title: String, content: String, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)!
        self.init(entity: entity, insertInto: context)
        self.title = title
        self.content = content
    }
}
