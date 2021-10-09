//
//  LyricizeApp.swift
//  Shared
//
//  Created by Samuel McGarry on 2021. 10. 9..
//

import SwiftUI

@main
struct LyricizeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
