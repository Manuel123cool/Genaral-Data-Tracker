//
//  OneEntrie.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 07.07.21.
//

import SwiftUI

struct EntrieMaker: View {
    @Binding var templateGroups: [[OneEntrieData]]
    @State private var dataEntrieTyp = DataEntrieTyp.quantity
    @State private var dataEntries: [OneEntrieData] = Array()
    @State private var header: String = ""
    @Binding var templateEntries: [OneEntrieData]

    @State private var stateDummy = [OneDataEntitiy]()
    var body: some View {
        VStack {
            DataTypSelect(dataEntrieTyp: $dataEntrieTyp)
            AddEntrie(dataEntries: $dataEntries, dataEntrieTyp: $dataEntrieTyp, templateGroups: $templateGroups)
            if dataEntries.count > 1 {
                HeaderTextField(header: $header)
                Divider()
            }
            DrawEntries(templateGroups: $templateGroups, dataEntries: $dataEntries,
                        header: $header, doInit: (false, -1),
                        dataEntities: $stateDummy)
            Spacer()
        }
        .navigationTitle("Select data entrie typ:")
        .onChange(of: dataEntries, perform: { newValue in
            templateEntries = newValue
        })
        .onChange(of: header, perform: { newValue in
            iniHeader(newValue: newValue)
        })
        .onAppear {
            UIApplication.shared.endEditing()
        }
        .onDisappear(perform: storeTemplates)
    }
    
    func storeTemplates() {
        if dataEntries.count > 0 {
            for (index, dataEntrie) in dataEntries.enumerated() {
                PersistenceController.shared.saveTemplate(dataEntrie, indexes: [templateGroups.count - 1, index])
            }
        }
    }
    
    func iniHeader(newValue: String) {
        for (index, _) in dataEntries.enumerated() {
            dataEntries[index].header = newValue
        }
    }
}

struct DataTypSelect: View {
    @Binding var dataEntrieTyp: DataEntrieTyp

    var body: some View {
        VStack {
            Picker(selection: $dataEntrieTyp, label: Text(""), content: {
                Text("Quantity").tag(DataEntrieTyp.quantity)
                Text("Yes/No").tag(DataEntrieTyp.yesOrNo)
                Text("Option").tag(DataEntrieTyp.options)
                Text("Note").tag(DataEntrieTyp.note)
            })
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: PercSize.width(100) - 30)
            .padding(.top, 10)
        }
    }
}

struct AddEntrie: View {
    @Binding var dataEntries: [OneEntrieData]
    @Binding var dataEntrieTyp: DataEntrieTyp
    @Binding var templateGroups: [[OneEntrieData]]
    
    var body: some View {
        HStack {
            Button(action: addEntrie, label: {
                Spacer()
                Text("Add")
                    .frame(width: PercSize.width(100) - 30)
                    .font(.title)
                    .foregroundColor(.blue)
                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.green))
                Spacer()
            })
        }
    }
    
    func addEntrie() {
        dataEntries.append(OneEntrieData(dataEntrieTyp: dataEntrieTyp))
        
        if dataEntries.count == 1 {
            templateGroups.append(dataEntries)
        }
    }
}

struct DrawEntries: View {
    @Binding var templateGroups: [[OneEntrieData]]
    @State private var dataTypes = Array(repeating: "", count: 100)
    @Binding var dataEntries: [OneEntrieData]
    @Binding var header: String

    let doInit: (Bool, Int)
    @Binding var dataEntities: [OneDataEntitiy]

    @State var showingAlert = false
    @State var deletIndexSet = IndexSet()
    
    var body: some View {
        List {
            ForEach(lookupArray, id: \.self) { index in
                if dataEntries[index].dataEntrieTyp == .quantity {
                    HStack {
                        DataTextField(placeHolder: "Pushups",
                                      fieldBinding: $dataTypes[index],
                                      widthPerc: 65)
                        Spacer()
                        DataEntrieTypText(text: "<Quantity>")
                    }
                } else if dataEntries[index].dataEntrieTyp == .note {
                    HStack {
                        DataEntrieTypText(text: "Note:")
                        Spacer()
                        DataTextField(placeHolder: "Note",
                                      fieldBinding: $dataTypes[index],
                                      widthPerc: 78)
                    }
                } else if dataEntries[index].dataEntrieTyp == .yesOrNo {
                    HStack {
                        DataTextField(placeHolder: "Did something",
                                      fieldBinding: $dataTypes[index],
                                      widthPerc: 65)
                        Spacer()
                        DataEntrieTypText(text: "<Yes/No>")
                    }
                } else {
                    HStack {
                        DataTextField(placeHolder: "Sport:",
                                      fieldBinding: $dataTypes[index],
                                      widthPerc: 44.5)
                        Spacer()
                        OptionsButton(dataEntrie: $dataEntries, index: index)
                    }
                }
            }.onDelete(perform: deletedEntrie)
        }
        .onChange(of: dataTypes, perform: initData)
        .onAppear(perform: initStates)
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text("Warning"), message: Text(alertText),
                  primaryButton: .destructive(Text("Delete")) {
                    deleteTemplate(indexSet: deletIndexSet)
                }, secondaryButton:
                    .default(Text("Cancel")))
        })
    }
 
    var alertText: String {
        var indexUse = -1
        for index in deletIndexSet {
            indexUse = index
        }
        let name = templateGroups[doInit.1][indexUse].data
        let objText = name == "" ? "_" : name
        return "Do you realy want to delete: \(objText) and all its history ?"
    }
    
    var lookupArray: [Int] {
        var reLookup = [Int]()
        for (index, _) in dataEntries.enumerated() {
            reLookup.append(index)
        }
        return reLookup
    }
    
    func deletedEntrie(indexSet: IndexSet) {
        if doInit.0 {
            deletIndexSet = indexSet
            showingAlert = true
            return
        }
        deleteTemplate(indexSet: indexSet)
    }
    
    func initStates() {
        guard doInit.0 else {
            return
        }
        for (index, template) in templateGroups[doInit.1].enumerated() {
            dataTypes[index] = template.data
            header = template.header
        }
    }
    
    func initData(newValue: [String]) {
        for (index, _) in dataEntries.enumerated() {
            dataEntries[index].header = self.header
            dataEntries[index].data = newValue[index]
        }
    }
    
    func deleteTemplate(indexSet: IndexSet) {
        self.dataEntries.remove(atOffsets: indexSet)
        self.dataTypes.remove(atOffsets: indexSet)
        self.dataTypes.append("")
        
        if dataEntries.count == 0 && !doInit.0 {
            templateGroups.removeLast()
        }
        
        if doInit.0 {
            for index in indexSet {
                ShowToolOptions.changeEntityOrder(&dataEntities, [doInit.1, index], false)
            }
        }
    }
}

struct OptionsButton: View {
    @Binding var dataEntrie: [OneEntrieData]
    @State private var showSheet = false
    let index: Int
 
    var body: some View {
        Button(action: {
            showSheet = true
        }, label: {
            Text("Edit Options")
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: PercSize.width(44.5), height: PercSize.width(4) + 19)
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.green))
        })
        .buttonStyle(BorderlessButtonStyle())
        .sheet(isPresented: $showSheet, content: {
                EditOtions(dataEntrie: $dataEntrie[index])
        })
    }
}

struct DataTextField: View {
    let placeHolder: String
    @Binding var fieldBinding: String
    let widthPerc: Float
    
    var body: some View {
        TextField(self.placeHolder, text: $fieldBinding,
                  onEditingChanged: {_ in},
            onCommit: {}
        )
        .frame(width: PercSize.width(self.widthPerc))
        .font(.system(size: PercSize.width(4)))
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct DataEntrieTypText: View {
    let text: String
    var body: some View {
        Text(self.text)
            .padding(.vertical ,PercSize.width(2))
    }
}

struct HeaderTextField: View {
    @Binding var header: String
    var body: some View {
        HStack {
            DataEntrieTypText(text: "Header:")
            Spacer()
            TextField("Header", text: $header,
                      onEditingChanged: { _ in },
                onCommit: {}
            )
            .frame(width: PercSize.width(73))
            .font(.system(size: PercSize.width(4)))
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .frame(width: PercSize.width(100) - 30)
        .padding(.horizontal, PercSize.width(4))
    }
}

struct OneEntrieData: Equatable {
    var id = UUID()
    var dataEntrieTyp: DataEntrieTyp
    var data = ""
    var options: [String] = []
    var header = ""
    var goal: Double = -1
    var biggerIsBetter = true
    var userSet = false
}

enum DataEntrieTyp: Int {
    case quantity = 0
    case yesOrNo = 1
    case options = 2
    case note = 3
}
