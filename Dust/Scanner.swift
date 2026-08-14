//
//  Scanner.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-11.
//

import SwiftData
import SwiftUI

@Observable
class Scanner
{
    var isScanning:Bool = false;
    var status:String = "Initializing...";
    var sgdbClient:SteamGridDbClient? = nil;
    
    func BeginScan()
    {
        _ = Task
        {
            return await self.ScanSafe();
        }
    }
    
    private func ScanSafe() async
    {
        if (self.isScanning)
        {
            return;
        }
        
        self.isScanning = true;
        do
        {
            try await self.Scan();
        }
        catch
        {
            print(error);
        }
        
        self.isScanning = false;
    }
    
    private func Scan() async throws
    {
        let storage = UserDefaults();
        let sgdbApiKey:String? = storage.string(forKey: "sgdbApiKey");
        
        if (sgdbApiKey != nil)
        {
            self.sgdbClient = SteamGridDbClient(apiKey: sgdbApiKey!);
            print("Connected to SGDB");
        }
        
        let platforms:[Platform] = try DustApp.container!.mainContext.fetch(FetchDescriptor<Platform>());
       
        for platform in platforms
        {
            try await self.Scan(platform: platform);
        }
        
        self.status = "Done";
        try await Task.sleep(for: .seconds(1))
    }
    
    private func Scan(platform:Platform) async throws
    {
        self.status = platform.name;
        
        let url:URL = URL(filePath: platform.directory);
        if (!url.startAccessingSecurityScopedResource())
        {
            print("Failed to get security scoped resource for path: \(url.absoluteString)");
            return;
        }
        
        do
        {
            let files:[String] = try FileManager.default.contentsOfDirectory(atPath: platform.directory);
            let pattern = try Regex(platform.searchPattern);
            
            for file in files
            {
                if (file.contains(pattern))
                {
                    try await Scan(platform:platform, file:file);
                }
            }
        }
        catch
        {
            print("error: \(error)");
        }
        
        url.stopAccessingSecurityScopedResource();
    }
    
    private func Scan(platform:Platform, file:String) async throws
    {
        let fileName = (file as NSString).lastPathComponent
        
        self.status = "\(platform.name) - \(fileName)";
        
        // not ideal, but fast enough for now.
        let games:[Game] = try DustApp.container!.mainContext.fetch(FetchDescriptor<Game>());
        var existingGame:Game? = nil;
        for game in games
        {
            if (game.file == file)
            {
                existingGame = game;
                break;
            }
        }
        
        if (existingGame == nil)
        {
            if (self.sgdbClient != nil)
            {
                let results = try await self.sgdbClient!.Search(term: fileName);
                
                if (results != nil && !results!.isEmpty)
                {
                    let sgdbGame = results![0];
                    print("Found: \"\(sgdbGame.name)\" for \"\(fileName)\"");
                    
                    existingGame = Game(title:sgdbGame.name, file:file);
                    existingGame!.sgdbId = sgdbGame.id;
                    existingGame!.platform = platform;
                    
                    // save
                    DustApp.container!.mainContext.insert(existingGame!);
                }
            }
        }
        
        // automatic metadata update
        if (existingGame != nil && existingGame?.sgdbId != nil && self.sgdbClient != nil)
        {
            if (existingGame!.coverUrl == nil)
            {
                let grids:[SteamGridDbObject]? = try await self.sgdbClient!.GetGrids(gameId: existingGame!.sgdbId!);
                if (grids != nil && !grids!.isEmpty)
                {
                    existingGame?.coverUrl = grids![0].thumb;
                }
            }
            
            if (existingGame!.logoUrl == nil)
            {
                let logos:[SteamGridDbObject]? = try await self.sgdbClient!.GetLogos(gameId: existingGame!.sgdbId!);
                if (logos != nil && !logos!.isEmpty)
                {
                    existingGame?.logoUrl = logos![0].thumb;
                }
            }
            
            let sgdbGame = try await self.sgdbClient!.GetGame(id: existingGame!.sgdbId);
            
            if (existingGame?.releaseYear == nil && sgdbGame!.release_date != nil)
            {
                existingGame?.releaseYear = sgdbGame!.release_date!.formatted(.dateTime.year());
            }
        }
    }
}

extension EnvironmentValues
{
    @Entry
    var scanner: Scanner = Scanner();
}
