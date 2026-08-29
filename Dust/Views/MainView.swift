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
    @Environment(\.colorScheme)
    var colorScheme;
    
    @Environment(\.modelContext)
    private var modelContext;
    
    @Environment(Scanner.self)
    var scanner:Scanner?;
    
    @Environment(GameManager.self)
    var gameManager:GameManager;
    
    @State
    private var search:String = "";
    
    var body: some View
    {
        @Bindable
        var bindableGameManager = gameManager;
        
        GamesView(searchTerm:search)
            .ignoresSafeArea(edges: .top)
        
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
        
        .toolbar
        {
            ToolbarItem
            {
                ProfileTagView()
                    .padding(.horizontal, 16)
            }
        }
        
        .searchable(text: $search)
        
        .onAppear
        {
            self.OnAppear();
        }
    }
    
    func OnAppear()
    {
        Services.Scanner.BeginScan();
    }
}

#Preview
{
    return MainView().withTestPlatforms();
}
