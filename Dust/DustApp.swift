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
    @State
    private var scanner = Scanner();
    
    var body: some Scene
    {
        WindowGroup
        {
            MainView()
                
        }.modelContainer(for: [
            Platform.self,
        ])
        .environment(self.scanner)
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
                .modelContainer(for: [
                    Platform.self,
                ]);
        }
    }
    
    func Scan()
    {
        scanner.BeginScan();
    }
}

