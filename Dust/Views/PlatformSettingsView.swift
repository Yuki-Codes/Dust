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
    
    @State
    var argsHelpPopupOpen:Bool = false;
    
    var body: some View
    {
        Form
        {
            TextField("Name", text: $platform.name);
            
            IconSelectorView(iconName: $platform.iconName, fallback: platform.name);
            
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
                
                HStack
                {
                    TextField("Arguments", text: $platform.launchArgs);
                    Image(systemName: "questionmark.circle.fill")
                    .popover(isPresented: $argsHelpPopupOpen)
                    {
                        VStack(alignment: .leading)
                        {
                            Text("The arguments to pass to the emulator when launching a game.")
                                .padding(.bottom, 2);
                            Text("the following substitutions will be performed:");
                            Text("{path} will be replaced with the absolute path to the file.");
                            Text("{file} will be replaced with the name of the file, including extension.");
                            Text("{title} will be replaced with the game title.");
                        }.padding(12);
                    }
                    .onHover
                    { over in
                        argsHelpPopupOpen = over;
                    }
                    
                }
                .padding(.vertical, 1);
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
    let testPlatform = Platform(name: "MacOS", iconName: "wpf:mac-os");
    PlatformSettingsView(platform: testPlatform)
        .frame(minWidth: 300, minHeight: 250)
        .padding(16);
}
