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
    
    init(title:String, file:String)
    {
        self.title = title;
        self.file = file;
    }
}

extension View
{
    func withTestGames() -> any View
    {
        let container: ModelContainer;
        let config = ModelConfiguration(isStoredInMemoryOnly: true);
        let schema = Schema(Game.self);
        
        do
        {
            container = try ModelContainer(for: schema, configurations: config);
            
            let testGame:Game = Game(title: "Doom", file:"test");
            testGame.sgdbId = 38598;
            testGame.coverUrl = "https://cdn2.steamgriddb.com/grid/ef58f7ffe086514aa0164c7fc4f6cea8.png";
            container.mainContext.insert(testGame);
        }
        catch
        {
            fatalError("The preview data couldn't be created")
        }
        
        return self.modelContainer(container);
    }
}
