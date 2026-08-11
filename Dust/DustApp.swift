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
        WindowGroup
        {
            MainView()
                
        }.modelContainer(for: [
            Platform.self
        ]);
        
        Settings
        {
            SettingsView()
                .modelContainer(for: [
                    Platform.self
                ]);
        }
    }
}
