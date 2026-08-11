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
    
    @Query(sort: \Platform.sortName)
    var platforms: [Platform];
    
    @AppStorage("sgdbApiKey")
    var sgdbApiKey: String = "";
    
    var SelectedPlatform:Platform?
    {
        return platforms.first(where:
        { platform in
            platform.id == platformId
        });
    }
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Text("SteamGridDB").font(.title3).frame(alignment: .leading);
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
            
            Text("Platforms").font(.title3);
            Text("Each platform specifies a directory to search for games.")
                .font(.caption)
                .foregroundStyle(.secondary);
            
            HStack
            {
                GroupBox
                {
                    List(platforms, selection: $platformId)
                    { platform in
                        HStack
                        {
                            if (platform.iconUrl != "")
                            {
                                CachedAsyncImage(url: URL(string: platform.iconUrl))
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
                                .frame(width: 14, height: 14)
                                Text(platform.name);
                            }
                            else
                            {
                                Text(platform.name).padding(Edge.Set.leading, 30);
                            }
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
                                Image(systemName: "plus");
                            }
                            .buttonStyle(.borderless)
                            .frame(width: 22, height: 22);
                            
                            Divider().frame(height: 14);
                            
                            Button(action:RemovePlatform)
                            {
                                Image(systemName: "minus");
                            }
                            .buttonStyle(.borderless)
                            .frame(width: 22, height: 22);
                        }
                        .buttonStyle(.borderless)
                        .frame(width: .infinity)
                    })
                }
                .formStyle(.grouped)
                .scrollDisabled(true)
                .frame(maxWidth: 200, maxHeight: 250)

                if (SelectedPlatform == nil)
                {
                    Text("Select a platform").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else
                {
                    PlatformSettingsView(platform: SelectedPlatform!)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(16)
                }
            }
            
        }.frame(minWidth: 450).padding(16)
        
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
    }
    
    func RemovePlatform()
    {
    }
}

#Preview
{
    SettingsView().withTestPlatforms();
}
