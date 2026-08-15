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
    @State private var scanner = Dust.Scanner();
    @State private var gameManager = Dust.GameManager();
    @State private var achievementsManager = Dust.AchievementsManager();
    @State private var sgdbClient:SteamGridDbClient = Dust.SteamGridDbClient();
    @State private var iconifyClient:IconifyClient = Dust.IconifyClient();
    @State private var retroAchievementsClient:RetroAchievementsClient = Dust.RetroAchievementsClient();
    
    public static var container:ModelContainer?;
    public static var instance:DustApp?;
    
    public static var SgdbClient:SteamGridDbClient?
    {
        return DustApp.instance?.sgdbClient;
    }
    
    public static var IconifyClient:IconifyClient?
    {
        return DustApp.instance?.iconifyClient;
    }
    
    public static var RetroAchievementsClient:RetroAchievementsClient?
    {
        return DustApp.instance?.retroAchievementsClient;
    }
    
    public static var AchievementsManager:Dust.AchievementsManager?
    {
        return DustApp.instance?.achievementsManager;
    }
    
    var body: some Scene
    {
        Window("Dust", id: "MainWindow")
        {
            MainView();
        }
        .modelContainer(DustApp.container!)
        .environment(self.scanner)
        .environment(self.gameManager)
        .environment(self.achievementsManager)
        .environment(self.sgdbClient)
        .environment(self.iconifyClient)
        .environment(self.retroAchievementsClient)
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
                .modelContainer(DustApp.container!)
                .environment(self.iconifyClient);
        }
    }
    
    init()
    {
        DustApp.instance = self;
        
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

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T>
{
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
