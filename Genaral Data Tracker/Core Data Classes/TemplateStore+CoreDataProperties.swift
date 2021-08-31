//
//  TemplateStore+CoreDataProperties.swift
//  Genaral Data Tracker
//
//  Created by Manuel Kümpel on 10.08.21.
//
//

import Foundation
import CoreData


extension TemplateStore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TemplateStore> {
        return NSFetchRequest<TemplateStore>(entityName: "TemplateStore")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var dataEntrieTyp: DataEntrieTyp?
    @NSManaged public var data: String?
    @NSManaged public var options: [String]?
    @NSManaged public var header: String?
    @NSManaged public var goal: Int64
    @NSManaged public var biggerIsBetter: Bool
    @NSManaged public var userSat: Bool
    @NSManaged public var indexes: [Int]?

}

extension TemplateStore : Identifiable {

}
