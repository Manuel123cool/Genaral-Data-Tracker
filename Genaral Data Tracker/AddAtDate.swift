//
//  AddAtDate.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 18.07.21.
//

import SwiftUI
import Combine

struct AddAtDate: View {
    @State private var stringStates = Array(repeating: "", count: 1)
    @State private var boolStates = Array(repeating: false, count: 1)

    let indexes: [Int]
    @Binding var dataEntities: [OneDataEntitiy]

    @Binding var templateGroups: [[OneEntrieData]]
    @Binding var isShowing: Bool

    @State var date = Date()

    var calcTemplate: OneEntrieData {
        if !isShowing || templateGroups[indexes[0]].count == 0 {
            return OneEntrieData(dataEntrieTyp: .note)
        }
        return templateGroups[indexes[0]][indexes[1]]
    }
    
    var body: some View {
        HStack {
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
            Spacer()
            if calcTemplate.dataEntrieTyp == .quantity {
                DrawTemplateTextField(binding: $stringStates, index: 0)
                AddToHistory(reAddHistoyInit(), date: calcDate)
            } else if calcTemplate.dataEntrieTyp == .yesOrNo {
                DrawTemplateToggle(binding: $boolStates, index: 0)
                AddToHistory(reAddHistoyInit(), date: calcDate)
            } else if calcTemplate.dataEntrieTyp == .options {
                DrawTemplatePicker(binding: $stringStates, index: 0,
                                   options: calcTemplate.options)
                AddToHistory(reAddHistoyInit(), date: calcDate)
            }
        }
        .frame(width: PercSize.width(100) - 30)
        .padding(.vertical, 5)
    }
    
    var calcDate: Date {
        if reCal().isDateInToday(date) {
            return Date()
        } else {
            return self.date
        }
    }
    
    func reAddHistoyInit() -> AddToHistoryTyp {
        return AddToHistoryTyp(
            index: indexes[0],
            inGroupIndex: indexes[1],
            templateGroups: templateGroups,
            dataEntities: $dataEntities,
            stringState: stringStates[0],
            boolState: boolStates[0]
        )
    }
}
