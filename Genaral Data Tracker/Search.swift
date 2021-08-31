//
//  Search.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 17.07.21.
//

import SwiftUI

struct Search {
    let templateGroups: [[OneEntrieData]]
    let searchWord: String

    func reLookupArray() -> [Int] {
        var reLookupArray: [Int] = []

        if searchWord == "" {
            for (index, group) in templateGroups.enumerated() {
                if group.count == 0 {
                    continue
                }
                reLookupArray.append(index)
            }
            return reLookupArray
        }
        
        for (index, templateGroup) in templateGroups.enumerated() {
            let template = templateGroup[0]
            let testString = templateGroup.count > 1 ? template.header : template.data
            
            let range = NSRange(location: 0, length: testString.utf16.count)
            let regex = try! NSRegularExpression(pattern: searchWord, options: .caseInsensitive)
            
            if regex.firstMatch(in: testString, options: [], range: range) != nil {
                reLookupArray.append(index)
            }
        }
        
        return reLookupArray
    }
}

