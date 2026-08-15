//
//  ContentView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-07-27.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct MainView: View
{
    @State
    private var platformId: UUID?;

    @Environment(\.colorScheme)
    var colorScheme;
    
    @Environment(\.modelContext)
    private var modelContext;
    
    @Query(sort: \Platform.sortName)
    var platforms: [Platform];
    
    @Environment(Scanner.self)
    var scanner:Scanner?;
    
    @Environment(GameManager.self)
    var gameManager:GameManager;
    
    var SelectedPlatform:Platform?
    {
        return platforms.first(where:
        { platform in
            platform.id == platformId
        });
    }
    
    var body: some View
    {
        @Bindable
        var bindableGameManager = gameManager;
        
        NavigationSplitView
        {
            VStack
            {
                List(platforms, selection: $platformId)
                { platform in
                    HStack
                    {
                        IconView(iconName: platform.iconName)
                            .frame(width: 20, height: 20);
                        Text(platform.name);

                    }
                };
            }
            .onAppear
            {
                self.OnAppear();
            }
        }
        
        detail:
        {
            GamesView(platform: self.SelectedPlatform)
                .ignoresSafeArea(edges: .top)
        }
        
        .overlay(alignment: .bottomTrailing)
        {
            ZStack
            {
                ZStack
                {
                    HStack
                    {
                        ProgressView().scaleEffect(0.75);
                        VStack(alignment: .leading)
                        {
                            Text("Scanning for games");
                            Text(scanner?.status ?? "No Scanner")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 256, alignment: .leading)
                                .lineLimit(1)
                        }
                    }
                    .padding(6)
                }
                .background(.thinMaterial)
                .cornerRadius(6)
            }
            .padding(16)
            .opacity(scanner?.isScanning != false ? 1.0 : 0)
            .animation(.easeInOut(duration: 0.25), value: scanner?.isScanning)
        }
        
        .sheet(isPresented: $bindableGameManager.isEditingGame)
        {
            VStack
            {
                EditGameView(game: bindableGameManager.editingGame!);

                Button("Done")
                {
                    gameManager.isEditingGame = false;
                }
            }
            .padding(12)
        }
        
        .sheet(isPresented: $bindableGameManager.isPlayingGame)
        {
            PlayingGameView(game: bindableGameManager.playingGame!);
        }
    }

    
    func OnAppear()
    {
        if (self.platforms.isEmpty)
        {
            let defaultPlatform:Platform = Platform(sortName:"Default", name:"Default", iconName: "line-md:question");
            self.modelContext.insert(defaultPlatform);
        }
        
        if (self.platformId == nil)
        {
            self.platformId = self.platforms.first?.id;
        }
    }
}

#Preview
{
    return MainView().withTestPlatforms();
}
