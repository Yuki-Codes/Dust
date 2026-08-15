//
//  ArtworkSelectorView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-15.
//

import SwiftUI

struct ArtworkSelectorView: View
{
    @Binding
    var game:Game;
    
    var type:ArtworkType;
    
    @Environment(SteamGridDbClient.self)
    var sgdbClient:SteamGridDbClient;
    
    @State
    private var searchResults: [SteamGridDbObject]?;
    
    @State
    private var isPopoverPresented: Bool = false;
    
    private var artUrl:String?
    {
        get
        {
            switch(type)
            {
                case .Cover: return game.coverUrl;
                case .Hero: return game.heroUrl;
                case .Logo: return game.logoUrl;
            }
        }
    }
    
    private var Label:String
    {
        get
        {
            switch(type)
            {
                case .Cover: return "Cover";
                case .Hero: return "Hero";
                case .Logo: return "Logo";
            }
        }
    }
    
    enum ArtworkType
    {
        case Cover;
        case Logo;
        case Hero;
    }
    
    func BeginSearch()
    {
        _ = Task
        {
            return await self.SearchSafe();
        }
    }
    
    func SearchSafe() async
    {
        do
        {
            if (game.sgdbId == nil)
            {
                return;
            }
            
            switch(self.type)
            {
            case .Cover:
                self.searchResults = try await sgdbClient.GetGrids(gameId: game.sgdbId!);
                break;
            case .Logo:
                self.searchResults = try await sgdbClient.GetLogos(gameId: game.sgdbId!);
                break;
            case .Hero:
                self.searchResults = try await sgdbClient.GetHeroes(gameId: game.sgdbId!);
                break;
            }
        }
        catch
        {
            print(error);
        }
    }
    
    var body: some View
    {
        Button(action:
        {
            isPopoverPresented = true;
            BeginSearch();
        })
        {
            VStack
            {
                ZStack
                {
                    Rectangle().opacity(0);
                    
                    if (artUrl != nil)
                    {
                        UrlImageView(url:artUrl!);
                    }
                }
                
                Text(self.Label);
            }
        }
        .popover(isPresented: $isPopoverPresented)
        {
            VStack
            {
                Text("Artwork provided by Steam Grid DB")
                    .font(Font.caption)
                    .opacity(0.5)
                
                if (self.searchResults != nil)
                {
                    ScrollView
                    {
                        LazyVGrid(
                            columns: [
                                GridItem(.fixed(100)),
                                GridItem(.fixed(100)),
                                GridItem(.fixed(100)),
                                GridItem(.fixed(100)),
                                GridItem(.fixed(100)),
                            ],
                            alignment: .leading,
                            spacing: 10
                        ) {
                            ForEach(searchResults!, id: \.self)
                            { result in
                                Button(action:
                                {
                                    self.SetArtwork(value: result.thumb);
                                    self.isPopoverPresented = false;
                                })
                                {
                                    UrlImageView(url:result.thumb);
                                }
                                .buttonStyle(.plain);
                            }
                        }
                    }
                    .frame(height: 400)
                }
                else
                {
                    Spacer()
                        .frame(height: 400)
                }
            }
            .padding(16);
        }
        .frame(height: 150)
    }
    
    func SetArtwork(value:String)
    {
        switch(type)
        {
        case .Cover:
            game.coverUrl = value;
            break;
        case .Hero:
            game.heroUrl = value;
            break;
        case .Logo:
            game.logoUrl = value;
            break;
        }
    }
}

#Preview
{
    let testPlatform = Platform(sortName: "A", name: "MacOS", iconName: "wpf:mac-os");
    PlatformSettingsView(platform: testPlatform)
        .frame(minWidth: 300, minHeight: 250)
        .padding(16);
}
