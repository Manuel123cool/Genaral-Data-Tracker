//
//  TemplateStore+CoreDataProperties.swift
//  Genaral Data Tracker
//
//  Created by Manuel Kümpel on 11.08.21.
//
//

import Foundation
import CoreData


extension TemplateStore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TemplateStore> {
        return NSFetchRequest<TemplateStore>(entityName: "TemplateStore")
    }

    @NSManaged public var biggerIsBetter: Bool
    @NSManaged public var data: String?
    @NSManaged public var dataEntrieTyp: String?
    @NSManaged public var goal: Double
    @NSManaged public var header: String?
    @NSManaged public var id: UUID?
    @NSManaged public var indexes: [Int]?
    @NSManaged public var options: [String]?
    @NSManaged public var userSet: Bool

}

extension TemplateStore : Identifiable {

}
