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
    
    @State
    private var gameManager = GameManager();
    
    public static var container:ModelContainer?;
    
    public static var iconify:IconifyClient? = nil;
    
    var body: some Scene
    {
        Window("MainWindow", id: "MainWindow")
        {
            MainView();
        }
        .modelContainer(DustApp.container!)
        .environment(self.scanner)
        .environment(self.gameManager)
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
            DustApp.iconify = IconifyClient();
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

