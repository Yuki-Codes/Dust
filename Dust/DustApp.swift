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
    
    public static var container:ModelContainer?;
    
    var body: some Scene
    {
        WindowGroup
        {
            MainView()
        }
        .modelContainer(DustApp.container!)
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
            SettingsView().modelContainer(DustApp.container!);
        }
    }
    
    init()
    {
        do
        {
            DustApp.container = try ModelContainer(for: Platform.self, Game.self);
        }
        catch
        {
            print("Error: \(error)");
        }
    }
    
    func Scan()
    {
        scanner.BeginScan();
    }
}

