//
//  Platform.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-10.
//

import SwiftData
import SwiftUI

@Model
class Platform: Identifiable, Hashable
{
    var name: String = "";
    var iconName: String = "";
    var id:UUID = UUID();
    var platformType: PlatformTypes = PlatformTypes.Applications;
    var executablePath: String = "";
    var directories:[String] = []
    var searchPattern: String = "[^.]+\\.app";
    var launchArgs: String = "{path}";
    
    enum PlatformTypes : Codable, CaseIterable, Identifiable, CustomStringConvertible
    {
        case Applications;
        case Emulator;
        
        var id: Self
        {
            return self;
        }
        
        var description: String
        {
            switch self
            {
            case PlatformTypes.Applications:
                return "Applications"
            case PlatformTypes.Emulator:
                return "Emulator"
            }
        }
    }
    
    init(name: String, iconName: String)
    {
        self.name = name;
        self.iconName = iconName;
        self.id = UUID();
    }
}

extension View
{
    func withTestPlatforms() -> any View
    {
        let container: ModelContainer;
        let config = ModelConfiguration(isStoredInMemoryOnly: true);
        let schema = Schema(Platform.self);
        
        do
        {
            container = try ModelContainer(for: schema, configurations: config);
            
            container.mainContext.insert(Platform(name: "PlayStation", iconName: "ri:playstation-fill"));
            container.mainContext.insert(Platform(name: "PlayStation 2", iconName: "ri:playstation-fill"));
            container.mainContext.insert(Platform(name: "PlayStation 3", iconName: "ri:playstation-fill"));
            container.mainContext.insert(Platform(name: "PlayStation 4", iconName: "ri:playstation-fill"));
            container.mainContext.insert(Platform(name: "XBOX", iconName: "mingcute:xbox-fill" ));
            container.mainContext.insert(Platform(name: "XBOX 360", iconName: "mingcute:xbox-fill"));
            container.mainContext.insert(Platform(name: "Windows", iconName: "gg:windows"));
            container.mainContext.insert(Platform(name: "MacOS", iconName: "wpf:mac-os"));
        }
        catch
        {
            fatalError("The preview data couldn't be created")
        }
        
        return self.modelContainer(container);
    }
}
