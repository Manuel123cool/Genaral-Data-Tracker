//
//  EditOtions.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 09.07.21.
//

import SwiftUI

struct EditOtions: View {
    @Binding var dataEntrie: OneEntrieData
    
    var body: some View {
        VStack {
            AddOption(dataEntrie: $dataEntrie)
            DrawOptions(dataEntrie: $dataEntrie)
            Spacer()
        }
    }
}

struct AddOption: View {
    @Binding var dataEntrie: OneEntrieData

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                dataEntrie.options.append("")
            }, label: {
                Spacer()
                Text("Add Option")
                    .frame(width: PercSize.width(90))
                    .font(.title)
                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.green))
                Spacer()
            })
        }
        .padding(.top, PercSize.width(5))
    }
}

struct DrawOptions: View {
    @Binding var dataEntrie: OneEntrieData
    var lookupArray: [Int] = []
    
    @State private var optionsStates: [String] = Array(repeating: "", count: 100)
    
    init(dataEntrie: Binding<OneEntrieData>) {
        self._dataEntrie = dataEntrie

        for (index, _) in self.dataEntrie.options.enumerated() {
            lookupArray.append(index)
        }
    }
    
    var body: some View {
        List {
            ForEach(lookupArray, id: \.self) { index in
                HStack {
                    Spacer()
                    OptionTextField(optionsStates: $optionsStates, index: index)
                    Spacer()
                }
            }.onDelete(perform: deleteOption)
        }
        .onAppear(perform: initStates)
        .onDisappear(perform: initOptions)
    }
    
    func initStates() {
        for (index, option) in dataEntrie.options.enumerated() {
            optionsStates[index] = option
        }
    }
    
    func initOptions()  {
        dataEntrie.options = []
        for option in optionsStates {
            if option == "" {
                return
            }
            dataEntrie.options.append(option)
        }
    }
    
    func deleteOption(indexSet: IndexSet) {
        self.dataEntrie.options.remove(atOffsets: indexSet)
        optionsStates.remove(atOffsets: indexSet)
        optionsStates.append("")
    }
}

struct OptionTextField: View {
    @Binding var optionsStates: [String]
    let index: Int
    var body: some View {
        TextField("Option \(index + 1)", text: $optionsStates[index],
                  onEditingChanged: {_ in },
            onCommit: {}
        )
        .frame(width: PercSize.width(90))
        .font(.system(size: PercSize.width(4)))
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
