//
//  DustApp.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-07-27.
//

import SwiftUI
import SwiftData



@main
struct DustApp: App
{
    var body: some Scene
    {
        Window("Dust", id: "MainWindow")
        {
            MainView();
        }
        .modelContainer(Services.Container)
        .environment(Services.Scanner)
        .environment(Services.GameManager)
        .environment(Services.SgdbClient)
        .environment(Services.IconifyClient)
        .commands
        {
            CommandMenu("Games")
            {
                Button("Scan for games", systemImage: "plus.viewfinder", action: Scan);
            }
        }
        
        Settings
        {
            SettingsView()
                .modelContainer(Services.Container)
                .environment(Services.IconifyClient);
        }
    }
    
    func Scan()
    {
        Services.Scanner.BeginScan();
    }
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T>
{
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
