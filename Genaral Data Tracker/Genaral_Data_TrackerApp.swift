//
//  Genaral_Data_TrackerApp.swift
//  Genaral Data Tracker
//
//  Created by Manuel Kümpel on 09.08.21.
//

import SwiftUI

@main
struct Genaral_Data_TrackerApp: App {
    @Environment(\.scenePhase) var scenePhase
            
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .background:
                print("Scene is in background")
                PersistenceController.shared.save()
            case .inactive:
                print("Scene is inactive")
            case .active:
                print("Scene is active")
            @unknown default:
                print("Apple must have changed something")
            }
        }
    }
}
