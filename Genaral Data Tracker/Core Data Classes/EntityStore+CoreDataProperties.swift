//
//  EntityStore+CoreDataProperties.swift
//  Genaral Data Tracker
//
//  Created by Manuel Kümpel on 10.08.21.
//
//

import Foundation
import CoreData


extension EntityStore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityStore> {
        return NSFetchRequest<EntityStore>(entityName: "EntityStore")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var indexRelatedTemplate: [Int]?
    @NSManaged public var stringState: String?
    @NSManaged public var boolState: Bool
    @NSManaged public var date: Date?

}

extension EntityStore : Identifiable {

}
