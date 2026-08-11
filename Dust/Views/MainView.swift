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
    
    var SelectedPlatform:Platform?
    {
        return platforms.first(where:
                                { platform in
            platform.id == platformId
        });
    }
    
    var body: some View
    {
        NavigationSplitView
        {
            VStack
            {
                List(platforms, selection: $platformId)
                { platform in
                    HStack
                    {
                        if (platform.iconUrl != nil)
                        {
                            CachedAsyncImage(url: URL(string: platform.iconUrl!))
                            { phase in
                                switch phase
                                {
                                case .success(let image):
                                    if colorScheme == ColorScheme.dark
                                    {
                                        image.resizable().colorInvert();
                                    }
                                    else
                                    {
                                        image.resizable();
                                    }
                                    
                                default:
                                    ProgressView().scaleEffect(0.5);
                                }
                            }
                            .frame(width: 20, height: 20)
                            Text(platform.name);
                        }
                        else
                        {
                            Text(platform.name).padding(Edge.Set.leading, 30);
                        }
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
            GamesView(platform: self.SelectedPlatform);
        }
        
        .overlay(alignment: .bottomTrailing)
        {
            GroupBox
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
            }
            .padding(16)
            .opacity(scanner?.isScanning != false ? 1.0 : 0)
            .animation(.easeInOut(duration: 0.25), value: scanner?.isScanning)
        }
    }
    
    func OnAppear()
    {
        if (self.platforms.isEmpty)
        {
            let defaultPlatform:Platform = Platform(sortName:"Default", name:"Default", iconUrl: nil);
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
