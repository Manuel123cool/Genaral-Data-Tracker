//
//  EdittGroup.swift
//  Genaral Data Tracker
//
//  Created by Manuel Kümpel on 14.08.21.
//

import SwiftUI

struct EditGroup: View {
    @Binding var templateGroups: [[OneEntrieData]]
    @Binding var dataEntities: [OneDataEntitiy]
    
    @State private var startEntries: [OneEntrieData] = []
    @State private var dataEntrieTyp = DataEntrieTyp.quantity
    @State private var lookupArray: [Int] = []
    @State private var header: String = ""

    let groupIndex: Int
    
    @Binding var showEditGroup: Bool

    var body: some View {
        VStack {
            DataTypSelect(dataEntrieTyp: $dataEntrieTyp)
            AddEntrie(dataEntries: $templateGroups[groupIndex],
                      dataEntrieTyp: $dataEntrieTyp,
                      templateGroups: $templateGroups)
            if templateGroups[groupIndex].count > 1 {
                HeaderTextField(header: $header)
                Divider()
            }
            DrawEntries(templateGroups: $templateGroups,
                        dataEntries: $templateGroups[groupIndex],
                        header: $header, doInit: (true, groupIndex),
                        dataEntities: $dataEntities)
            Spacer()
        }
        .padding(.top, 5)
        .onChange(of: header, perform: updateHeader)
        .onDisappear(perform: disappearFunc)
    }
    
    func disappearFunc() {
        showEditGroup = false
        PersistenceController.shared.checkForEditGroup(templateGroups[groupIndex], groupIndex)
    }
    
    func updateHeader(newValue: String) {
        for (index1, _) in templateGroups[groupIndex].enumerated() {
            templateGroups[groupIndex][index1].header = newValue
        }
    }
}
