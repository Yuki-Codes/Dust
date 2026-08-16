//
//  Services.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-16.
//


import SwiftUI
import SwiftData

class Services
{
    private static let instance:Services = Services();
    
    private let scanner = Dust.Scanner();
    private let gameManager = Dust.GameManager();
    private let achievementsManager = Dust.AchievementsManager();
    private let sgdbClient:SteamGridDbClient = Dust.SteamGridDbClient();
    private let iconifyClient:IconifyClient = Dust.IconifyClient();
    private let retroAchievementsClient:RetroAchievementsClient = Dust.RetroAchievementsClient();
    private let modelContainer:ModelContainer?
    
    public static var Scanner:Dust.Scanner
    {
        return Services.instance.scanner;
    }
    
    public static var GameManager:Dust.GameManager
    {
        return Services.instance.gameManager;
    }
    
    public static var AchievementsManager:Dust.AchievementsManager
    {
        return Services.instance.achievementsManager;
    }
    
    public static var SgdbClient:Dust.SteamGridDbClient
    {
        return Services.instance.sgdbClient;
    }
    
    public static var IconifyClient:Dust.IconifyClient
    {
        return Services.instance.iconifyClient;
    }
    
    public static var RetroAchievementsClient:Dust.RetroAchievementsClient
    {
        return Services.instance.retroAchievementsClient;
    }
    
    public static var Container:ModelContainer
    {
        return Services.instance.modelContainer!;
    }
    
    init()
    {
        do
        {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true);
            self.modelContainer = try ModelContainer(for: Platform.self, Game.self, configurations:configuration);
        }
        catch
        {
            self.modelContainer = nil;
            print("Error: \(error)");
        }
    }
}
