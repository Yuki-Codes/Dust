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
    var sortName: String = "";
    var name: String = "";
    var iconUrl: String? = nil;
    var id:UUID = UUID();
    var platformType: PlatformTypes = PlatformTypes.Applications;
    var executablePath: String = "";
    var directory: String = "";
    var searchPattern: String = "[^.]+\\.app";
    
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
            switch self {
            case PlatformTypes.Applications:
                return "Applications"
            case PlatformTypes.Emulator:
                return "Emulator"
            }
        }
    }
    
    init(sortName:String, name: String, iconUrl: String?, id:UUID, platformType:PlatformTypes, executablePath:String, directory:String)
    {
        self.sortName = sortName;
        self.name = name;
        self.iconUrl = iconUrl;
        self.id = id;
        self.platformType = platformType;
        self.executablePath = executablePath;
        self.directory = directory;
    }
    
    init(sortName:String, name: String, iconUrl: String?)
    {
        self.sortName = sortName;
        self.name = name;
        self.iconUrl = iconUrl;
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
            
            container.mainContext.insert(Platform(sortName:"CPS1", name: "PlayStation", iconUrl: "https://api.iconify.design/ri:playstation-fill.svg"));
            container.mainContext.insert(Platform(sortName:"CPS2", name: "PlayStation 2", iconUrl: "https://api.iconify.design/thesvg:playstation-2.svg"));
            container.mainContext.insert(Platform(sortName:"CPS3", name: "PlayStation 3", iconUrl: "https://api.iconify.design/thesvg:playstation-3.svg"));
            container.mainContext.insert(Platform(sortName:"CPS4", name: "PlayStation 4", iconUrl: "https://api.iconify.design/thesvg:playstation-4.svg"));
            container.mainContext.insert(Platform(sortName:"CXB1", name: "XBOX", iconUrl: "https://api.iconify.design/mingcute:xbox-fill.svg" ));
            container.mainContext.insert(Platform(sortName:"CXB2", name: "XBOX 360", iconUrl: "https://api.iconify.design/mingcute:xbox-fill.svg"));
            container.mainContext.insert(Platform(sortName:"AWN", name: "Windows", iconUrl: "https://api.iconify.design/gg:windows.svg"));
            container.mainContext.insert(Platform(sortName:"AMC", name: "MacOS", iconUrl: "https://api.iconify.design/wpf:mac-os.svg"));
        }
        catch
        {
            fatalError("The preview data couldn't be created")
        }
        
        return self.modelContainer(container);
    }
}
