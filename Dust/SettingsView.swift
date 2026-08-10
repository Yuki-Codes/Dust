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
    }
    
    init()
    {
        self.platformId = platforms.first?.id;
    }
    
    func AddPlatform()
    {
    }
}

struct PlatformSettingsView : View
{
    @Bindable
    var platform:Platform;
    
    var body: some View
    {
        Form
        {
            TextField("Name", text: $platform.name);
            TextField("Sorting Name", text: $platform.sortName);
            //TextField("Icon", text: $platform.iconUrl);
        }
            
    }
}

#Preview
{
    SettingsView().withTestPlatforms();
}
