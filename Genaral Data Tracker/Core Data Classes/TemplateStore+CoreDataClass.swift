//
//  TemplateStore+CoreDataClass.swift
//  Genaral Data Tracker
//
//  Created by Manuel Kümpel on 10.08.21.
//
//

import Foundation
import CoreData

@objc(TemplateStore)
public class TemplateStore: NSManagedObject {
    var state: State {
            // To get a State enum from stateValue, initialize the
            // State type from the Int32 value stateValue
            get {
                return State(rawValue: self.stateValue)!
            }

            // newValue will be of type State, thus rawValue will
            // be an Int32 value that can be saved in Core Data
            set {
                self.stateValue = newValue.rawValue
            }
        }
}
