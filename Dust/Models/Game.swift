//
//  Game.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-11.
//


import SwiftData
import SwiftUI

@Model
class Game: Identifiable, Hashable
{
    var title:String;
    var sgdbId:Int?;
    var file:String;
    var coverUrl:String?;
    var logoUrl:String?;
    var releaseYear:String?;
    var platform:Platform?;
    var heroUrl:String?;
    
    init(title:String, file:String)
    {
        self.title = title;
        self.file = file;
    }
    
    public static func TestGame(index:Int = 0) -> Game
    {
        let testGame:Game = Game(title: "Doom \(index)", file:"test");
        testGame.sgdbId = 2460;
        testGame.coverUrl = "https://cdn2.steamgriddb.com/grid/ef58f7ffe086514aa0164c7fc4f6cea8.png";
        testGame.logoUrl = "https://cdn2.steamgriddb.com/logo_thumb/6a3b6ffa5dbf8a5abcad2135e5bc77d9.png";
        testGame.heroUrl = "https://cdn2.steamgriddb.com/hero_thumb/442465f5282183631234848d916ce365.jpg";
        return testGame;
    }
}

extension View
{
    func withTestGames(count:Int = 10) -> any View
    {
        let container: ModelContainer;
        let config = ModelConfiguration(isStoredInMemoryOnly: true);
        let schema = Schema(Game.self);
        
        do
        {
            container = try ModelContainer(for: schema, configurations: config);
            
            for i in stride(from: 0, to: count, by: 1)
            {
                container.mainContext.insert(Game.TestGame(index:i));
            }
         
        }
        catch
        {
            fatalError("The preview data couldn't be created")
        }
        
        return self.modelContainer(container);
    }
}
