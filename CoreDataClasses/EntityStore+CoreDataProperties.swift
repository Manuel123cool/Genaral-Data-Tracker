//
//  EntityStore+CoreDataProperties.swift
//  Genaral Data Tracker
//
//  Created by Manuel Kümpel on 11.08.21.
//
//

import Foundation
import CoreData


extension EntityStore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityStore> {
        return NSFetchRequest<EntityStore>(entityName: "EntityStore")
    }

    @NSManaged public var boolState: Bool
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var indexRelatedTemplate: [Int]?
    @NSManaged public var stringState: String?

}

extension EntityStore : Identifiable {

}
