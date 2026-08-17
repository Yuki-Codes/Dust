//
//  PlatformsEditorView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-07-27.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct SettingsView: View
{
    @State
    private var platformId: UUID?;
    
    @Environment(\.colorScheme)
    var colorScheme;
    
    @Environment(\.modelContext)
    private var modelContext;
    
    @Query
    var platforms: [Platform];
    
    @AppStorage("sgdbApiKey")
    var sgdbApiKey: String = "";
    
    @AppStorage("raApiKey")
    var raApiKey: String = "";
    
    @AppStorage("raUserName")
    var raUserName: String = "";
    
    var SelectedPlatform:Platform?
    {
        return platforms.first(where:
        { platform in
            platform.id == platformId
        });
    }
    
    var body: some View
    {
        TabView
        {
            VStack(alignment: .leading)
            {
                HStack
                {
                    GroupBox
                    {
                        List(platforms, selection: $platformId)
                        { platform in
                            HStack
                            {
                                IconView(iconName: platform.iconName)
                                    .frame(width: 14, height: 14);
                                    
                                Text(platform.name);
                            }
                        }
                        .padding(.bottom, 24)
                        .padding(.top, -4)
                        .padding(.horizontal, -4)
                        .listStyle(.plain)
                        .overlay(alignment: .bottomLeading, content:
                        {
                            HStack(spacing: 0)
                        {
                            Button(action:AddPlatform)
                            {
                                ZStack
                                {
                                    Rectangle().opacity(0);
                                    Image(systemName: "plus");
                                }
                            }
                            .frame(width: 22, height: 22);
                            
                            Divider().frame(height: 14);
                            
                            Button(action:RemovePlatform)
                            {
                                ZStack
                                {
                                    Rectangle().opacity(0);
                                    Image(systemName: "minus");
                                }
                            }
                            .frame(width: 22, height: 22);
                        }
                        .buttonStyle(.borderless)
                        })
                    }
                    .formStyle(.grouped)
                    .scrollDisabled(true)
                    .frame(width: 200)

                    if (SelectedPlatform == nil)
                    {
                        Text("Select a platform").frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    else
                    {
                        PlatformSettingsView(platform: SelectedPlatform!)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
            }
            .tabItem
            {
                Label("Platforms", systemImage: "gamecontroller.fill")
            }
            
            VStack(alignment: .leading)
            {
                Text("Steam Grid Database").font(.title3).frame(alignment: .leading);
                Text("Enter a Steam Grid Database API Key to automatically fetch cover art and metadata for your games.")
                    .font(.caption)
                    .foregroundStyle(.secondary);
                
                Link("Get an API key from the SGDB preferences page.", destination: URL(string: "https://www.steamgriddb.com/profile/preferences/api")!)
                    .font(.caption);
                Form
                {
                    TextField("API Key", text: $sgdbApiKey);
                }
                
                Spacer().frame(height: 32);
                
                Text("Retro Achievements").font(.title3).frame(alignment: .leading);
                Text("Enter a Retro Achievements API Key to fetch achievement progress for your games.")
                    .font(.caption)
                    .foregroundStyle(.secondary);
                
                Link("Get an API key from the Retro Achievements settings page.", destination: URL(string: "https://retroachievements.org/settings?tab=applications")!)
                    .font(.caption);
                Form
                {
                    TextField("User Name", text: $raUserName);
                    TextField("API Key", text: $raApiKey);
                }
                
                Spacer().frame(height: 32);
            }
            .tabItem
            {
                Label("Integrations", systemImage: "link")
            }
        }
        .frame(width: 600).padding(16)
        
        .onAppear
        {
            self.OnAppear();
        }
    }
    
    func OnAppear()
    {
        self.platformId = platforms.first?.id;
    }
    
    func AddPlatform()
    {
        let platform:Platform = Platform(name: "New Platform", iconName: "line-md:question");
        self.modelContext.insert(platform);
        self.platformId = platform.id;
    }
    
    func RemovePlatform()
    {
        if (self.SelectedPlatform == nil)
        {
            return;
        }
        
        self.modelContext.delete(self.SelectedPlatform!);
        
        if (!self.platforms.isEmpty)
        {
            self.platformId = self.platforms[0].id;
        }
    }
}

#Preview
{
    SettingsView().withTestPlatforms();
}
