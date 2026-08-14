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
    
    init()
    {
        let storage = UserDefaults();
        let sgdbApiKey:String? = storage.string(forKey: "sgdbApiKey");
        
        if (sgdbApiKey != nil)
        {
            self.sgdbClient = SteamGridDbClient(apiKey: sgdbApiKey!);
            print("Connected to SGDB");
        }
    }
    
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
    
    func BeginGetMetadata(game:Game, force:Bool)
    {
        _ = Task
        {
            return await self.GetMetadataSafe(game:game, force:force);
        }
    }
    
    private func GetMetadataSafe(game:Game, force:Bool) async
    {
        if (self.isScanning)
        {
            return;
        }
        
        self.isScanning = true;
        do
        {
            try await self.GetMetadata(game: game, force: force);
        }
        catch
        {
            print(error);
        }
        
        self.isScanning = false;
    }
    
    private func Scan() async throws
    {
        if (self.sgdbClient == nil)
        {
            return;
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
        
        print(platform.name);
        
        let url:URL = URL(filePath: platform.directory);
        if (!url.startAccessingSecurityScopedResource())
        {
            print("Failed to get security scoped resource for path: \(url.absoluteString)");
            return;
        }
        
        do
        {
            try await Scan(platform: platform, dir:platform.directory);
        }
        catch
        {
            print("error: \(error)");
        }
        
        url.stopAccessingSecurityScopedResource();
    }
    
    private func Scan(platform:Platform, dir:String) async throws
    {
        let files:[String] = try FileManager.default.contentsOfDirectory(atPath: dir);
        let pattern = try Regex(platform.searchPattern);
        
        for file in files
        {
            let path:String = dir.appending(file);
            
            var isDir: ObjCBool = false;
            FileManager.default.fileExists(atPath: path, isDirectory: &isDir);
            
            if (file.contains(pattern))
            {
                try await Scan(platform:platform, file:file);
            }
            else if(isDir.boolValue)
            {
                try await Scan(platform:platform, dir: path);
            }
        }
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
        
        // Try get SGDB game
        if (existingGame == nil && self.sgdbClient != nil)
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
        
        // fallback to direct game
        if (existingGame == nil)
        {
            existingGame = Game(title:fileName, file:file);
            existingGame!.platform = platform;
        }
        
        // automatic metadata update
        if (existingGame != nil)
        {
            try await GetMetadata(game:existingGame!, force:false);
        }
    }
    
    private func GetMetadata(game:Game, force:Bool) async throws
    {
        if (self.sgdbClient == nil)
        {
            return;
        }
        
        if (game.sgdbId == nil)
        {
            return;
        }
        
        let sgdbGame = try await self.sgdbClient!.GetGame(id: game.sgdbId);
        if (sgdbGame == nil)
        {
            return;
        }
        
        if (force)
        {
            game.title = sgdbGame!.name;
        }
        
        if (sgdbGame!.release_date != nil && (force || game.releaseYear == nil))
        {
            game.releaseYear = sgdbGame!.release_date!.formatted(.dateTime.year());
        }
        
        if (force || game.coverUrl == nil)
        {
            let grids:[SteamGridDbObject]? = try await self.sgdbClient!.GetGrids(gameId: game.sgdbId!);
            if (grids != nil && !grids!.isEmpty)
            {
                game.coverUrl = grids![0].thumb;
            }
        }
        
        if (force || game.logoUrl == nil)
        {
            let logos:[SteamGridDbObject]? = try await self.sgdbClient!.GetLogos(gameId: game.sgdbId!);
            if (logos != nil && !logos!.isEmpty)
            {
                game.logoUrl = logos![0].thumb;
            }
        }
        
        if (force || game.heroUrl == nil)
        {
            let heroes:[SteamGridDbObject]? = try await self.sgdbClient!.GetHeroes(gameId: game.sgdbId!);
            if (heroes != nil && !heroes!.isEmpty)
            {
                game.heroUrl = heroes![0].thumb;
            }
        }
    }
}

extension EnvironmentValues
{
    @Entry
    var scanner: Scanner = Scanner();
}
