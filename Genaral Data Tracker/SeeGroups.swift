//
//  SeeGroup.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 11.07.21.
//

import SwiftUI

struct SeeGroup: View {
    @Binding var templateGroups: [[OneEntrieData]]
    let index: Int
    @Binding var dataEntities: [OneDataEntitiy]
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
                DrawDrawTampletesViewGroup(templateGroups: $templateGroups,
                                           dataEntities: $dataEntities,
                                           groupIndex: index, header: header,
                                           isShowingGroup: $isShowing)
        }
        .onDisappear(perform: {ShowHistoryList.delZeroGroups(&templateGroups, &dataEntities)})
    }
    
    var header: String {
        if !templateGroups.indices.contains(index) {
            return ""
        } else if !templateGroups[index].indices.contains(0) {
            return ""
        }
        return templateGroups[index][0].header
    }
}

struct DrawDrawTampletesViewGroup: View {
    @State private var stringStates = Array(repeating: "", count: 500)
    @State private var boolStates = Array(repeating: false, count: 500)

    var lookupArray: [Int] = []
    let groupIndex: Int
    @Binding var dataEntities: [OneDataEntitiy]
    
    @Binding private var templateGroups: [[OneEntrieData]]

    let header: String
    
    @Binding var isShowingGroup: Bool

    @State private var showEditGroup = false
        
    init(templateGroups: Binding<[[OneEntrieData]]>,
         dataEntities: Binding<[OneDataEntitiy]>, groupIndex: Int,
         header: String, isShowingGroup: Binding<Bool>) {
        
        self._templateGroups = templateGroups
        self._dataEntities = dataEntities
        self.header = header
        self.groupIndex = groupIndex
        self._isShowingGroup = isShowingGroup
        
        for (index, _) in self.templateGroups[groupIndex].enumerated() {
            lookupArray.append(index)
        }
    }
    
    var body: some View {
        List {
            ForEach(lookupArray, id: \.self) { index in
                if templateGroups[groupIndex][index].dataEntrieTyp == .note {
                    HStack {
                        Text(templateGroups[groupIndex][index].data)
                        SeeEditNote(templateGroups: $templateGroups,
                                    indexes: [groupIndex, index], barIsHidden: false,
                                    isShowingGroup: $isShowingGroup)
                    }
                } else if templateGroups[groupIndex][index].dataEntrieTyp == .quantity {
                    HStack {
                        ShowHistoryButton(reShowHistoyInit(index: index))
                        Spacer()
                        DrawTemplateTextField(binding: $stringStates, index: index)
                        AddToHistory(reAddHistoyInit(index: index))
                    }
                } else if templateGroups[groupIndex][index].dataEntrieTyp == .yesOrNo {
                    HStack {
                        ShowHistoryButton(reShowHistoyInit(index: index))
                        Spacer()
                        DrawTemplateToggle(binding: $boolStates, index: index)
                        AddToHistory(reAddHistoyInit(index: index))
                    }
                } else if templateGroups[groupIndex][index].dataEntrieTyp == .options {
                    HStack {
                        ShowHistoryButton(reShowHistoyInit(index: index))
                        Spacer()
                        DrawTemplatePicker(binding: $stringStates, index: index,
                                           options: templateGroups[groupIndex][index].options)
                        AddToHistory(reAddHistoyInit(index: index))
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {showEditGroup = true}, label: {
                        Image(systemName: "pencil.circle")
                            .font(.title2)
                            .padding(.trailing, 5)
                    })
                    .sheet(isPresented: $showEditGroup, content: {
                        EditGroup(templateGroups: $templateGroups,
                                   dataEntities: $dataEntities,
                                   groupIndex: groupIndex,
                                   showEditGroup: $showEditGroup)
                                   
                    })
                    
                    Button("Add All", action: addAll)
                }
            }
        }
        .navigationTitle(header)
    }
    
    func addAll() {
        UIApplication.shared.endEditing()
        for (index, _) in templateGroups[groupIndex].enumerated() {
             dataEntities.append(
                OneDataEntitiy(templateData: templateGroups[groupIndex][index],
                               indexRelatedTemplate: [groupIndex, index],
                               stringState: stringStates[index],
                               boolState: boolStates[index],
                               date: Date()))
            PersistenceController.shared.saveEntity(dataEntities.last!)
        }
    }
    
    func reAddHistoyInit(index: Int) -> AddToHistoryTyp {
        return AddToHistoryTyp(
            index: groupIndex,
            inGroupIndex: index,
            templateGroups: templateGroups,
            dataEntities: $dataEntities,
            stringState: stringStates[index],
            boolState: boolStates[index]
        )
    }
    
    func reShowHistoyInit(index: Int) -> ShowHistoryTyp {
        return ShowHistoryTyp(
            text: templateGroups[groupIndex][index].data,
            indexes: [groupIndex, index],
            dataEntities: $dataEntities,
            templateGroups: $templateGroups,
            barIsHidden: false,
            isShowingGroup: $isShowingGroup
        )
    }
}
