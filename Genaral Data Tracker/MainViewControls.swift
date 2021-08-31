//
//  MainViewControls.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 07.07.21.
//

import SwiftUI

struct MainViewControls: View {
    @Binding var templateGroups: [[OneEntrieData]]
    @Binding var templateEntries: [OneEntrieData]
    @Binding var searchWord: String

    var body: some View {
        HStack() {
            SearchField(searchWord: $searchWord)
            Spacer()
            NewButton(templateGroups: $templateGroups, templateEntries: $templateEntries)
        }
        .padding(EdgeInsets(top: PercSize.width(2),
                            leading: PercSize.width(1.5),
                            bottom: PercSize.width(2),
                            trailing: PercSize.width(1.5))
        )
        .background(Color.blue)
    }
}

struct SearchField: View {
    @Binding var searchWord: String

    var body: some View {
        TextField("Search", text: $searchWord,
                  onEditingChanged: { (returnType) in },
                  onCommit: {}
        )
        .frame(width: PercSize.width(60))
        .font(.system(size: PercSize.heigth(3)))
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .foregroundColor(.blue)
        .onDisappear {
            searchWord = ""
        }
    }
}

struct NewButton: View {
    @Binding var templateGroups: [[OneEntrieData]]
    @Binding var templateEntries: [OneEntrieData]

    var body: some View {
        NavigationLink(destination: EntrieMaker(templateGroups: $templateGroups, templateEntries: $templateEntries)) {
            Text("New")
                .font(.title)
                .foregroundColor(.blue)
                .frame(height: PercSize.heigth(3))
                .padding(PercSize.width(2))
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.green))
        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
    }
}
