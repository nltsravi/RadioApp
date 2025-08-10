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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
