//
//  Platform.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-10.
//

import SwiftData
import SwiftUI

@Model
class Platform: Identifiable, Hashable {
    var name: String = ""
    var iconName: String = ""
    var id: UUID = UUID()
    var type: PlatformType = PlatformType.applications
    var executablePath: String = ""
    var directories: [String] = []
    var searchPattern: String = "[^.]+\\.app"
    var launchArgs: String = "{path}"
    var retroArchCore: String?

    enum PlatformType: Codable, CaseIterable, Identifiable, CustomStringConvertible {
        case applications
        case emulator

        var id: Self {
            return self
        }

        var description: String {
            switch self {
            case PlatformType.applications:
                return "Applications"
            case PlatformType.emulator:
                return "Emulator"
            }
        }
    }

    init(name: String, iconName: String) {
        self.name = name
        self.iconName = iconName
        self.id = UUID()
    }
}

extension View {
    func withTestPlatforms() -> any View {
        let container: ModelContainer
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema(Platform.self)

        do {
            container = try ModelContainer(for: schema, configurations: config)

            container.mainContext.insert(Platform(name: "PlayStation", iconName: "ri:playstation-fill"))
            container.mainContext.insert(Platform(name: "PlayStation 2", iconName: "ri:playstation-fill"))
            container.mainContext.insert(Platform(name: "PlayStation 3", iconName: "ri:playstation-fill"))
            container.mainContext.insert(Platform(name: "PlayStation 4", iconName: "ri:playstation-fill"))
            container.mainContext.insert(Platform(name: "Windows", iconName: "gg:windows"))
            container.mainContext.insert(Platform(name: "MacOS", iconName: "wpf:mac-os"))
        } catch {
            fatalError("The preview data couldn't be created")
        }

        return self.modelContainer(container)
    }
}
