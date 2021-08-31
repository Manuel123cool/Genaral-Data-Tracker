//
//  ContentView.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 07.07.21.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {    
    @State private var templateGroups: [[OneEntrieData]] = Array()
    @State private var templateEntries: [OneEntrieData] = Array()
    @State private var dataEntities: [OneDataEntitiy] = Array()
    @State private var searchWord = ""
    
    var body: some View {
        NavigationView {
            VStack {
                MainViewControls(templateGroups: $templateGroups,
                                 templateEntries: $templateEntries,
                                 searchWord: $searchWord)

                DrawTemplates(templateGroups: $templateGroups,
                              templateEntries: $templateEntries,
                              dataEntities: $dataEntities,
                              searchWord: $searchWord)
                Spacer()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: initStates)
    }
    
    func initStates() {
        let templates = PersistenceController.shared.initTemplates(&templateGroups)
        PersistenceController.shared.initEntities(&dataEntities, templates)
    }
}

struct OneDataEntitiy: Identifiable, Equatable {
    var id = UUID()
    let templateData: OneEntrieData
    var indexRelatedTemplate: [Int]
    var stringState: String = ""
    var boolState: Bool = false
    var date: Date
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 11")
    }
}
