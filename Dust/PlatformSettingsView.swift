//
//  PlatformSettingsView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-11.
//


import CachedAsyncImage
import SwiftData
import SwiftUI

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
                            self.platform.executablePath = panel.url?.path() ?? "";
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
                        self.platform.directory = panel.url?.path() ?? "";
                    }
                }
            }
            
            TextField("Search Pattern", text: $platform.searchPattern);
        }
    }
}

#Preview
{
    var testPlatform = Platform(sortName: "A", name: "MacOS", iconUrl: "https://api.iconify.design/wpf:mac-os.svg");
    PlatformSettingsView(platform: testPlatform)
        .frame(minWidth: 300, minHeight: 250)
        .padding(16);
}
