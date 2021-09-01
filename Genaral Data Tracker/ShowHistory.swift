//
//  ShowHistory.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 13.07.21.
//

import SwiftUI

struct ShowHistory: View {
    @Binding var dataEntities: [OneDataEntitiy]

    let indexes: [Int]
    let header: String
    
    @Binding var templateGroups: [[OneEntrieData]]

    @Binding var isShowing: Bool

    @State private var selected = 0
    
    @Binding var isShowingGroup: Bool
    
    let fromGroup: Bool
    var body: some View {
        VStack {
            AddAtDate(indexes: indexes, dataEntities: $dataEntities,
                      templateGroups: $templateGroups, isShowing: $isShowing)
            Divider()
            if linkLength > 1 {
                LinkList(length: linkLength, selected: $selected)
            }
            ShowHistoryList(dataEntities: $dataEntities, indexes: indexes,
                            header: header, templateGroups: $templateGroups,
                            isShowing: $isShowing,
                            usedDataEntities: ShowHistory.reUsedEntities(dataEntities, indexes).0[selected],
                            selected: $selected,
                            isShowingGroup: $isShowingGroup)
        }
        .onDisappear(perform: delZeroGroups)
    }
    
    var linkLength: Int {
        ShowHistory.reUsedEntities(dataEntities, indexes).length
    }
    
    func delZeroGroups() {
        if !fromGroup {
            ShowHistoryList.delZeroGroups(&templateGroups, &dataEntities)
        }
    }
    
    static func reUsedEntities(_ dataEntities: [OneDataEntitiy], _ indexes: [Int]) -> ([[OneDataEntitiy]], length: Int) {
        let sortedEntities = sortDates(usedDataEntities: dataEntities)
        
        var usedDataEntities: [OneDataEntitiy] = []
        for entity in sortedEntities {
            if entity.indexRelatedTemplate == indexes {
                usedDataEntities.append(entity)
            }
        }
        var inGroups: [[OneDataEntitiy]] = [[]]
        
        for (index, usedDataEntitie) in usedDataEntities.enumerated() {
            if index > inGroups.count * 15 - 1 {
                inGroups.append([])
            }
            inGroups[inGroups.count - 1].append(usedDataEntitie)
        }
        
        return (inGroups, length: inGroups.count)
    }
}

struct ShowHistoryButton: View {
    @State var isShowing = false
    let text: String
    let indexes: [Int]
    @Binding var dataEntities: [OneDataEntitiy]
    @Binding var templateGroups: [[OneEntrieData]]
    var barIsHidden = true

    @Binding var isShowingGroup: Bool

    init(_ showHistoryTyp: ShowHistoryTyp) {
        text = showHistoryTyp.text
        indexes = showHistoryTyp.indexes
        _dataEntities = showHistoryTyp.$dataEntities
        _templateGroups = showHistoryTyp.$templateGroups
        barIsHidden = showHistoryTyp.barIsHidden
        _isShowingGroup = showHistoryTyp.$isShowingGroup
    }
    
    var body: some View {
        Button(action: isShowingToTrue, label: {
            Text(text)
        })
        if barIsHidden {
            navLink
        } else {
            navLink
                .navigationBarHidden(false)
        }
    }
    
    func isShowingToTrue() {
        UIApplication.shared.endEditing()
        isShowing = true
    }
    
    var navLink: some View {
        NavigationLink(destination: ShowHistory(dataEntities: $dataEntities,
                                                indexes: indexes, header: text,
                                                templateGroups: $templateGroups,
                                                isShowing: $isShowing,
                                                isShowingGroup: $isShowingGroup,
                                                fromGroup: !barIsHidden),
                       isActive: $isShowing) { EmptyView() }
            .frame(width: 0)
            .opacity(0)
    }
}

struct LinkList: View {
    var length: Int
    @Binding var selected: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(0..<length, id: \.self) { index in
                    Text("\(index + 1)")
                        .onTapGesture {
                            selected = index
                        }
                        .frame(minWidth: PercSize.width(8), minHeight: PercSize.heigth(4))
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.green))
                }
            }
        }
    }
}

struct ShowHistoryList: View {
    @Binding var dataEntities: [OneDataEntitiy]
    let usedDataEntities: [OneDataEntitiy]
    
    let indexes: [Int]
    let header: String
    
    @Binding var templateGroups: [[OneEntrieData]]
    @Binding var isShowing: Bool
    @Binding var selected: Int

    @Binding var isShowingGroup: Bool

    init(dataEntities: Binding<[OneDataEntitiy]>, indexes: [Int], header: String,
            templateGroups: Binding<[[OneEntrieData]]>,
            isShowing: Binding<Bool>, usedDataEntities: [OneDataEntitiy], selected: Binding<Int>,
            isShowingGroup: Binding<Bool>) {
        
        self._dataEntities = dataEntities
        self._templateGroups = templateGroups
        self.indexes = indexes
        self.header = header
        self._isShowing = isShowing
        self.usedDataEntities = usedDataEntities
        self._selected = selected
        self._isShowingGroup = isShowingGroup
    }
    
    var body: some View {
        List {
            ForEach(usedDataEntities, id: \.id) { entity in
                if entity.templateData.dataEntrieTyp == .quantity {
                    HStack {
                        Text(entity.stringState)
                        Spacer()
                        Text("\(entity.date, formatter: dateFormatter)")
                    }
                } else if entity.templateData.dataEntrieTyp == .yesOrNo {
                    HStack {
                        Text(entity.boolState ? "Yes" : "No")
                        Spacer()
                        Text("\(entity.date, formatter: dateFormatter)")
                    }
                } else if entity.templateData.dataEntrieTyp == .options {
                    HStack {
                        Text(entity.stringState)
                        Spacer()
                        Text("\(entity.date, formatter: dateFormatter)")
                    }
                }
            }
            .onDelete(perform: deleteDataEntity)
        }
        .listStyle(PlainListStyle())
        .onChange(of: templateGroups, perform: { newValue in
            templateGroups = newValue
        })
        .navigationTitle(header)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShowToolOptions(header: header, templateGroups: $templateGroups, indexes: indexes,
                                dataEntities: $dataEntities, isShowing: $isShowing,
                                isShowingGroup: $isShowingGroup)
            }
        }
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    static func delZeroGroups(_ templateGroups: inout [[OneEntrieData]],
                              _ dataEntities: inout [OneDataEntitiy]) {
        var deleteIndex = -1
        for (index, group) in templateGroups.enumerated() {
            if group.count == 0 {
                deleteIndex = index
            }
        }
        
        if deleteIndex != -1 {
            templateGroups.remove(at: deleteIndex)
            
            for (index, entity) in dataEntities.enumerated() {
                if entity.indexRelatedTemplate[0] > deleteIndex {
                    dataEntities[index].indexRelatedTemplate[0] -= 1
                }
            }
        }
    }
    
    func deleteDataEntity(indexSet: IndexSet) {
        for index in indexSet {
            let fromReUsed = ShowHistory.reUsedEntities(dataEntities, indexes).0
            
            var startCount = false
            var overallIndex = 0
            for (index1, group) in fromReUsed.enumerated() {
                for (index2, _) in group.enumerated() {
                    if startCount {
                        overallIndex += 1
                    }
                    if index1 == selected && index2 == index {
                        startCount = true
                    }
                }
            }
            print(overallIndex)
            PersistenceController.shared.deleteEntity(dataEntities[overallIndex].id)
            dataEntities.remove(at: overallIndex)
        }
        
        if usedDataEntities.count == 1 && selected > 0 {
            selected -= 1
        }
    }
}

func sortDates(usedDataEntities: [OneDataEntitiy]) -> [OneDataEntitiy] {
    var deleteEntities = usedDataEntities
    var reEntities: [OneDataEntitiy] = []
    
    while deleteEntities.count > 0 {
        var earliestDateEntity = deleteEntities[0]
        for deleteEntitie in deleteEntities {
            if deleteEntitie.date >= earliestDateEntity.date {
                earliestDateEntity = deleteEntitie
            }
        }
        reEntities.append(earliestDateEntity)
        
        for (index, entitiy) in deleteEntities.enumerated() {
            if entitiy.id == earliestDateEntity.id {
                deleteEntities.remove(at: index)
            }
        }
    }
    return reEntities
}

struct ShowToolOptions: View {
    let header: String
    @Binding var templateGroups: [[OneEntrieData]]
    
    let indexes: [Int]
    @Binding var dataEntities: [OneDataEntitiy]
    
    @Binding var isShowing: Bool

    @State private var showSheetAchievements = false
    @State private var showSheetBarGraph = false
    @State private var showSheetLineGraph = false
    @State private var showEditGroup = false

    @State private var whichView: WhichView = .none
    
    @State var showingAlert = false

    @Binding var isShowingGroup: Bool

    var body: some View {
        Button(action: {
        }, label: {
            Menu {
                if isQuantity {
                    Button("Show Line Graph", action: {showSheetLineGraph = true})
                }
                Button("Show Bar Graph", action: {showSheetBarGraph = true})
                Button("Show Achievements", action: {showSheetAchievements = true})
                   
                Button(action: { showingAlert = true },
                label: {
                    HStack {
                        Text("Delete: \(header)")
                        Spacer()
                        Image(systemName: "trash")
                    }
                })
                Button(action: { showEditGroup = true },
                label: {
                    HStack {
                        Text("Edit: \(header)")
                        Spacer()
                        Image(systemName: "pencil.circle")
                    }
                })
            }
            label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
            }
        })
        .sheet(isPresented: $showSheetLineGraph, content: {
            GraphDataprovider(dataEntities: dataEntities,
                              templateGroups: templateGroups, indexes: indexes, isBarGraph: false)
        })
        .sheet(isPresented: $showSheetAchievements, content: {
            DrawAchivements(indexes: indexes,
                            dataEntities: dataEntities,
                            template: $templateGroups[indexes[0]][indexes[1]])
        })
        .sheet(isPresented: $showSheetBarGraph, content: {
            GraphDataprovider(dataEntities: dataEntities,
                              templateGroups: templateGroups, indexes: indexes, isBarGraph: true)
        })
        .sheet(isPresented: $showEditGroup, content: {
            EditGroup(templateGroups: $templateGroups,
                       dataEntities: $dataEntities,
                       groupIndex: indexes[0],
                       showEditGroup: $showEditGroup)
                       
        })
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text("Warning"), message: Text(alertText),
                  primaryButton: .destructive(Text("Delete")) {
                    deleteTemplate()
                }, secondaryButton:
                    .default(Text("Cancel")))
        })
    }
    
    var isQuantity: Bool {
        if !templateGroups.indices.contains(indexes[0]) ||
            !templateGroups[indexes[0]].indices.contains(indexes[1]) {
            
            return true
        }
        if templateGroups[indexes[0]][indexes[1]].dataEntrieTyp == .quantity {
            return true
        }
        return false
    }
    
    var alertText: String {
        let name = templateGroups[indexes[0]][indexes[1]].data
        let objText = name == "" ? "_" : name
        return "Do you realy want to delete: \(objText) and all its history ?"
    }
    
    func deleteTemplate() {
        let getsZero = templateGroups[indexes[0]].count == 1 ? true : false
        PersistenceController.shared.deleteTemplate(templateGroups[indexes[0]][indexes[1]].id, getsZero)
        
        var groupWasDeleted = false
        if templateGroups[indexes[0]].count == 1 {
            templateGroups.remove(at: indexes[0])
            groupWasDeleted = true
        } else {
            templateGroups[indexes[0]].remove(at: indexes[1])
            if templateGroups[indexes[0]].count == 1 {
                isShowingGroup = false
            }
        }
        
        ShowToolOptions.changeEntityOrder(&dataEntities, indexes, groupWasDeleted)
        
        isShowing = false
    }
    
    static func changeEntityOrder(_ dataEntities: inout [OneDataEntitiy],
                                  _ indexes: [Int],
                                  _ groupWasDeleted: Bool) {
        
        var count = 0
        for entity in dataEntities {
            if entity.indexRelatedTemplate == indexes {
                dataEntities.remove(at: count)
                count -= 1
            }
            count += 1
        }
        
        if groupWasDeleted {
            for (index, entity) in dataEntities.enumerated() {
                if entity.indexRelatedTemplate[0] > indexes[0] {
                    dataEntities[index].indexRelatedTemplate[0] = entity.indexRelatedTemplate[0] - 1
                }
            }
        } else {
            var usedEntites: [OneDataEntitiy] = []
            
            for dataEntitie in dataEntities {
                if dataEntitie.indexRelatedTemplate[0] == indexes[0] {
                    usedEntites.append(dataEntitie)
                }
            }
            
            for (index, entity) in usedEntites.enumerated() {
                if entity.indexRelatedTemplate[1] > indexes[1] {
                    usedEntites[index].indexRelatedTemplate[1] = entity.indexRelatedTemplate[1] - 1
                }
            }
            
            for usedEntity in usedEntites {
                for (index1, allEntity) in dataEntities.enumerated() {
                    if usedEntity.id == allEntity.id {
                        dataEntities[index1] = usedEntity
                    }
                }
            }
        }
    }
}

enum WhichView {
    case none, lineGraph, barGraph, achievements
}

struct ShowHistoryTyp {
    let text: String
    let indexes: [Int]
    @Binding var dataEntities: [OneDataEntitiy]
    @Binding var templateGroups: [[OneEntrieData]]
    let barIsHidden: Bool
    
    @Binding var isShowingGroup: Bool
}
