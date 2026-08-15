//
//  EditGameView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct EditGameView: View
{
    @Environment(Scanner.self)
    var scanner:Scanner?;
    
    @Environment(AchievementsManager.self)
    var achivementsManager:AchievementsManager?;
    
    @Environment(SteamGridDbClient.self)
    var sgdb:SteamGridDbClient;
    
    @State
    var game:Game;
    
    @State
    var searchTerm:String = "";
    
    @State
    private var searchResults: [SteamGridDbGame]?;
    
    @State
    var isPopoverPresented:Bool = false;
    
    @State
    var selectedSgdbGame:Int = 0;
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Form
            {
                HStack
                {
                    TextField("steamgriddb.com/game/", value: $game.sgdbId, formatter: NumberFormatter());
                    
                    Button(action:
                    {
                        self.isPopoverPresented = true;
                        self.BeginSearch();
                    })
                    {
                        Image(systemName: "magnifyingglass");
                    }
                    
                    Button(action:{
                        scanner!.BeginGetMetadata(game: game, force: true);
                    })
                    {
                        if (self.scanner!.isScanning)
                        {
                            ProgressView().scaleEffect(0.4);
                        }
                        else
                        {
                            Image(systemName: "square.and.arrow.down");
                        }
                    }
                }
                .popover(isPresented: $isPopoverPresented)
                {
                    VStack
                    {
                        TextField("Search", text: $searchTerm)
                            .onSubmit(BeginSearch);
                        
                        Text("Metadata and artwork provided by the Steam Grid Database")
                            .font(Font.caption)
                            .opacity(0.5)
                        
                        if (self.searchResults != nil)
                        {
                            List(searchResults!, selection: $game.sgdbId)
                            { sgdbGame in
                                HStack
                                {
                                    Text(sgdbGame.name).lineLimit(1);
                                    
                                    let releaseYear:String = sgdbGame.release_date?.formatted(.dateTime.year()) ?? "";
                                    Text(releaseYear)
                                        .foregroundStyle(.secondary);
                                }
                            }
                            .frame(height: 200)
                            .listStyle(.plain)
                        }
                        else
                        {
                            Spacer()
                                .frame(height: 200)
                        }
                    }
                    .frame(width: 400)
                    .padding(16);
                }
            }
            
            Text("Find this game on the Steam Grid Database to download artwork and metadata.")
                .font(.caption)
                .foregroundStyle(.secondary);
            
            Spacer().frame(height: 32);
            
            Form
            {
                TextField("Title", text: $game.title);
                TextField("Release Year", text: $game.releaseYear ?? "");
                //Toggle("Hidden from library", isOn: $game.hidden).toggleStyle(.checkbox);
                
                HStack
                {
                    ArtworkSelectorView(game: $game, type: .Cover);
                    ArtworkSelectorView(game: $game, type: .Logo);
                    ArtworkSelectorView(game: $game, type: .Hero);
                }
                
                TextField("Arguments", text: $game.customLaunch ?? "", prompt:Text(game.platform?.launchArgs ?? ""));
                Text("Override the default launch arguments for this game.")
                    .font(.caption)
                    .foregroundStyle(.secondary);
            }
            
            Spacer().frame(height: 32);
            
            Form
            {
                HStack
                {
                    TextField("retroachievements.org/game/", value: $game.raId, formatter: NumberFormatter());
                    
                    Button(action:{
                        achivementsManager!.BeginUpdateAchievments(game: game);
                    })
                    {
                        Image(systemName: "square.and.arrow.down");
                    }
                }
            }
            
            Text("Find this game on Retro Achievements to show achievement progress")
                .font(.caption)
                .foregroundStyle(.secondary);
            
            Text("There are \(game.achievements.count) achivements for this game")
                .font(.caption)
                .foregroundStyle(.secondary);
            
            Spacer().frame(height: 32);
            
            HStack
            {
                Text("Path: ")
                    .font(.caption);
                Text(game.path)
                    .font(.caption);
            }
            
            if (game.platform?.platformType == .Emulator)
            {
                HStack
                {
                    Text("Executable: ")
                        .font(.caption);
                    
                    Text(game.platform?.executablePath ?? "")
                        .font(.caption);
                }
            }
        }
    }
    
    func BeginSearch()
    {
        if (self.searchTerm == "")
        {
            self.searchTerm = game.title;
        }
        
        _ = Task
        {
            return await self.SearchSafe();
        }
    }
    
    func SearchSafe() async
    {
        do
        {
            self.searchResults = try await self.sgdb.Search(term: self.searchTerm);
        }
        catch
        {
            print(error);
        }
    }
}

#Preview
{
    EditGameView(game: Game.TestGame())
        .padding(12)
}
