//
//  RadioAppApp.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import SwiftUI

@main
struct RadioAppApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var qsoViewModel: QSOViewModel
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _qsoViewModel = StateObject(wrappedValue: QSOViewModel(context: context))
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(qsoViewModel)
        }
    }
}
