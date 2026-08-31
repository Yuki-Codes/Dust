//
//  DustApp.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-07-27.
//

import SwiftUI
import SwiftData

@main
struct DustApp: App {
    var body: some Scene {
        Window("Dust", id: "MainWindow") {
            MainView()
        }
        .modelContainer(Services.Container)
        .environment(Services.Scanner)
        .environment(Services.GameManager)
        .environment(Services.SgdbClient)
        .environment(Services.IconifyClient)
        .commands {
            CommandMenu("Games") {
                Button("Scan for games", systemImage: "plus.viewfinder", action: Services.Scanner.beginScan)
            }
        }

        Settings {
            SettingsView()
                .modelContainer(Services.Container)
                .environment(Services.IconifyClient)
        }
    }
}

func ?? <T>(lhs: Binding<T?>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
