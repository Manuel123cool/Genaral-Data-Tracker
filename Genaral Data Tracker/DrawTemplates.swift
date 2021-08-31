//
//  DrawEntries.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 10.07.21.
//

import SwiftUI
import Combine

struct DrawTemplates: View {
    @Binding var templateGroups: [[OneEntrieData]]
    @Binding var templateEntries: [OneEntrieData]
    @Binding var dataEntities: [OneDataEntitiy]
    @Binding var searchWord: String

    var body: some View {
        DrawTampletesView(templateGroups: $templateGroups,
                              dataEntities: $dataEntities,
                              templateEntries: $templateEntries,
                              searchWord: $searchWord)
    }
}

struct DrawTampletesView: View {
    @State private var stringStates = Array(repeating: "", count: 500)
    @State private var boolStates = Array(repeating: false, count: 500)

    @Binding var templateGroups: [[OneEntrieData]]

    @Binding var dataEntities: [OneDataEntitiy]
    
    @Binding var templateEntries: [OneEntrieData]

    @Binding var searchWord: String

    @State private var dummyState = false
    init(templateGroups: Binding<[[OneEntrieData]]>,
         dataEntities: Binding<[OneDataEntitiy]>, templateEntries: Binding<[OneEntrieData]>,
            searchWord: Binding<String>) {
        
        self._templateGroups = templateGroups
        self._dataEntities = dataEntities
        self._templateEntries = templateEntries
        self._searchWord = searchWord
        
        if self.templateEntries.count > 0 && self.templateGroups.count > 0 {
            let groupIndex = self.templateGroups.count - 1
            self.templateGroups[groupIndex] = self.templateEntries
            self.templateEntries = []
        }
    }
    
    var body: some View {
        List {
            ForEach(lookupArray, id: \.self) { index in
                if templateGroups.count != 0 && templateGroups[index].count == 1 {
                    if templateGroups[index][0].dataEntrieTyp == .note {
                        HStack {
                            Text(templateGroups[index][0].data)
                            SeeEditNote(templateGroups: $templateGroups,
                                        indexes: [index, 0], barIsHidden: true, isShowingGroup: $dummyState)
                        }
                    } else if templateGroups[index][0].dataEntrieTyp == .quantity {
                        HStack {
                            ShowHistoryButton(reShowHistoyInit(index: index))
                            Spacer()
                            DrawTemplateTextField(binding: $stringStates, index: index)
                            AddToHistory(reAddHistoyInit(index: index))
                        }

                    } else if templateGroups[index][0].dataEntrieTyp == .yesOrNo {
                        HStack {
                            ShowHistoryButton(reShowHistoyInit(index: index))
                            Spacer()
                            DrawTemplateToggle(binding: $boolStates, index: index)
                            AddToHistory(reAddHistoyInit(index: index))
                        }

                    } else if templateGroups[index][0].dataEntrieTyp == .options {
                        HStack {
                            ShowHistoryButton(reShowHistoyInit(index: index))
                            Spacer()
                            DrawTemplatePicker(binding: $stringStates, index: index,
                                               options: templateGroups[index][0].options)
                            AddToHistory(reAddHistoyInit(index: index))
                        }
                    }
                } else if templateGroups.count != 0 && templateGroups[index].count > 1 {
                    HStack {
                        Text(templateGroups[index][0].header)
                        Spacer()
                        GroupSeeAll(templateGroups: $templateGroups,
                                    index: index, dataEntities: $dataEntities)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    var lookupArray: [Int] {
        let search = Search(templateGroups: self.templateGroups, searchWord: self.searchWord)
        return search.reLookupArray()
    }
    
    func resetStates() {
        stringStates = Array(repeating: "", count: 500)
        boolStates = Array(repeating: false, count: 500)
    }
    
    func reShowHistoyInit(index: Int) -> ShowHistoryTyp {
        return ShowHistoryTyp(
            text: templateGroups[index][0].data,
            indexes: [index, 0],
            dataEntities: $dataEntities,
            templateGroups: $templateGroups,
            barIsHidden: true,
            isShowingGroup: $dummyState
        )
    }
    
    func reAddHistoyInit(index: Int) -> AddToHistoryTyp {
        return AddToHistoryTyp(
            index: index,
            inGroupIndex: 0,
            templateGroups: templateGroups,
            dataEntities: $dataEntities,
            stringState: stringStates[index],
            boolState: boolStates[index]
        )
    }
}

struct SeeEditNote: View {
    @Binding var templateGroups: [[OneEntrieData]]
    let indexes: [Int]
    @State var isShowing = false
    let barIsHidden: Bool

    @Binding var isShowingGroup: Bool

    var body: some View {
        ZStack {
            Button(action: isShowingToTrue, label: {
                EmptyView()
            })
            if barIsHidden {
                navLink
                    
            } else {
                navLink
                    .navigationBarHidden(false)
            }
        }
    }
    
    var navLink: some View {
        NavigationLink(destination: EditNote(templateGroups: $templateGroups,
                                             goBack: $isShowing, indexes: indexes,
                                             isShowingGroup: $isShowingGroup),
                       isActive: $isShowing) { EmptyView() }
    }
    
    func isShowingToTrue() {
        UIApplication.shared.endEditing()
        isShowing = true
    }
}

struct EditNote: View {
    @Binding var templateGroups: [[OneEntrieData]]
    @Binding var goBack: Bool
    let indexes: [Int]
    
    @State private var note = ""
    @State private var deletedNote = false
    
    @Binding var isShowingGroup: Bool
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: deleteNote, label: {
                    Spacer()
                    Text("Delete")
                        .frame(width: PercSize.width(100) - 30)
                        .font(.title)
                        .foregroundColor(.blue)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.red))
                    Spacer()
                })
            }
            .padding(.top, 10)
            HStack {
                Spacer()
                HStack {
                    DataEntrieTypText(text: "Edit:")
                    Spacer()
                    DataTextField(placeHolder: "Note",
                                  fieldBinding: $note,
                                  widthPerc: 78)
                }
                .frame(width: PercSize.width(100) - 30)
                Spacer()
            }
            Spacer()
        }
        .navigationTitle("Note Edit")
        .onAppear {
            note = templateGroupData.data
        }
        .onChange(of: note, perform: { newValue in
            templateGroups[indexes[0]][indexes[1]].data = newValue
        })
        .onDisappear(perform: storeEdit)
    }
    
    var templateGroupData: OneEntrieData {
        templateGroups[indexes[0]][indexes[1]]
    }
    
    func deleteNote() {
        let getsZero = templateGroups[indexes[0]].count == 1 ? true : false
        PersistenceController.shared.deleteTemplate(templateGroupData.id, getsZero)
        templateGroups[indexes[0]].remove(at: indexes[1])
        deletedNote = true
        goBack = false
        if templateGroups[indexes[0]].count == 1 {
            isShowingGroup = false
        }
    }
    
    func storeEdit() {
        if !deletedNote {
            PersistenceController.shared.updateTemplateData(note, templateGroupData.id)
        }
    }
}

struct GroupSeeAll: View {
    @Binding var templateGroups: [[OneEntrieData]]
    let index: Int
    @State var isShowing = false
    @Binding var dataEntities: [OneDataEntitiy]

    var body: some View {
        ZStack {
            Button(action: isShowingToTrue, label: {
                EmptyView()
            })
            NavigationLink(destination: SeeGroup(templateGroups: $templateGroups, index: index,
                                                 dataEntities: $dataEntities, isShowing: $isShowing),
                           isActive: $isShowing) { EmptyView() }
                .navigationBarHidden(true)
                .navigationBarTitle("", displayMode: .inline)
        }
    }
    
    func isShowingToTrue() {
        UIApplication.shared.endEditing()
        isShowing = true
    }
}

struct DrawTemplateTextField: View {
    @Binding var binding: [String]
    let index: Int

    var body: some View {
        TextField("", text: $binding[index],
            onEditingChanged: {_ in},
            onCommit: {}
        )
        .frame(width: PercSize.width(20))
        .font(.system(size: PercSize.width(4)))
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .keyboardType(.decimalPad)
        .onReceive(Just(binding[index])) { newValue in
            let filtered = DrawTemplateTextField.filterReceive(newValue: newValue)
            if filtered != newValue {
                binding[index] = filtered
            }
        }
        .labelsHidden()
    }
    
    static func filterReceive(newValue: String) -> String {
        var filtered = newValue.filter { "0123456789.,".contains($0) }
        
        var count = 0
        var once = false
        for char in filtered {
            let isPoint = char == "," || char == "."

            if isPoint && !once {
                once = true
                count += 1
            } else if isPoint && once {
                filtered.remove(at: filtered.index(filtered.startIndex, offsetBy: count))
            } else {
                count += 1
            }
        }
        return filtered
    }
}

struct DrawTemplateToggle: View {
    @Binding var binding: [Bool]
    let index: Int

    var body: some View {
        Toggle(isOn: $binding[index], label: {})
            .labelsHidden()
    }
}

struct DrawTemplatePicker: View {
    @Binding var binding: [String]
    let index: Int
    let options: [String]
    
    var body: some View {
        Picker(selection: $binding[index], label: HStack {
            Text("Select")
                .font(.title)
                .foregroundColor(.green)
                .padding(.horizontal, 5)
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.blue))
        }, content: {
            ForEach(0..<options.count, id: \.self) {
                Text(options[$0]).tag(options[$0])
            }
        })
        .pickerStyle(MenuPickerStyle())
        .labelsHidden()
    }
}

struct AddToHistory: View {
    let index: Int
    let inGroupIndex: Int
    let templateGroups: [[OneEntrieData]]
    @Binding var dataEntities: [OneDataEntitiy]
    var stringState: String
    var boolState: Bool
    let date: Date
    
    init(_ addToHistoryTyp: AddToHistoryTyp, date: Date = Date()) {
        self.index = addToHistoryTyp.index
        self.inGroupIndex = addToHistoryTyp.inGroupIndex
        self.templateGroups = addToHistoryTyp.templateGroups
        self._dataEntities = addToHistoryTyp.$dataEntities
        self.stringState = addToHistoryTyp.stringState
        self.boolState = addToHistoryTyp.boolState
        self.date = date
    }
    
    var body: some View {
        Button(action: appendEntitie, label: {
            Text("Add")
                .font(.title)
                .foregroundColor(.blue)
                .padding(.horizontal, 5)
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.orange))
        })
        .buttonStyle(BorderlessButtonStyle())
    }
    
    func appendEntitie() {
        UIApplication.shared.endEditing()
        dataEntities.append(OneDataEntitiy(templateData: templateGroups[index][inGroupIndex],
                                           indexRelatedTemplate: [index, inGroupIndex],
                                           stringState: stringState,
                                           boolState: boolState,
                                           date: date))
        PersistenceController.shared.saveEntity(dataEntities.last!)
    }
}

struct AddToHistoryTyp {
    let index: Int
    let inGroupIndex: Int
    let templateGroups: [[OneEntrieData]]
    @Binding var dataEntities: [OneDataEntitiy]
    var stringState: String
    var boolState: Bool
}
