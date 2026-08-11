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
    
    var SelectedPlatform:Platform?
    {
        return platforms.first(where:
        { platform in
            platform.id == platformId
        });
    }
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Picker(selection: $platformId, label: Text("Platform"))
                {
                    ForEach(platforms)
                    { platform in
                        Text(platform.name).tag(platform.id);
                    }
                }
                .buttonSizing(.flexible)
                
                Button(action:AddPlatform)
                {
                    Label("Add", systemImage: "plus");
                }
            }
            
            GroupBox
            {
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
            
        }.frame(minWidth: 600, minHeight: 400).padding(16)
        
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
}

struct PlatformSettingsView : View
{
    @Environment(\.modelContext)
    private var modelContext;
    
    @Bindable
    var platform:Platform;
    
    var body: some View
    {
        Form
        {
            TextField("Name", text: $platform.name);
            TextField("Sorting Name", text: $platform.sortName);
            //TextField("Icon", text: $platform.iconUrl);
            
            Picker("Type", selection: $platform.platformType)
            {
                ForEach(Platform.PlatformTypes.allCases)
                { platformType in
                    Text(String(describing: platformType))
                    
                }
            }
            .buttonSizing(.flexible);
            
            if (self.platform.platformType == Platform.PlatformTypes.Emulator)
            {
                HStack
                {
                    TextField("Executable", text: $platform.executablePath)
                    Button("...")
                    {
                        let panel = NSOpenPanel();
                        panel.allowsMultipleSelection = false;
                        panel.canChooseDirectories = false;
                        if panel.runModal() == .OK
                        {
                            self.platform.executablePath = panel.url?.absoluteString ?? "";
                        }
                    }
                }
            }
            
            HStack
            {
                TextField("Directory", text: $platform.directory)
                Button("...")
                {
                    let panel = NSOpenPanel();
                    panel.allowsMultipleSelection = false;
                    panel.canChooseDirectories = true;
                    panel.canChooseFiles = false;
                    if panel.runModal() == .OK
                    {
                        self.platform.directory = panel.url?.absoluteString ?? "";
                    }
                }
            }
            
            TextField("Search Pattern", text: $platform.searchPattern);
        }
    }
}

#Preview
{
    SettingsView().withTestPlatforms();
}
