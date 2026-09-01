//
//  Game.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-11.
//

import SwiftData
import SwiftUI

@Model
class Configuration: Identifiable, Comparable {
    var title: String = ""
    var releaseYear: String?
    var coverUrl: String?
    var logoUrl: String?
    var iconUrl: String?
    var heroUrl: String?
    var launchArgs: String?
    var sortTitle: String = ""
    var position: Int = 0
    var canLaunch: Bool = true

    init() {
    }

    static func < (lhs: Configuration, rhs: Configuration) -> Bool {
        return lhs.position < rhs.position
    }
}

@Model
class Game: Identifiable, Hashable, Comparable {
    var path: String
    var platform: Platform?
    var hidden: Bool = false
    var foundInScan: Bool = false
    var configurations: [Configuration] = []

    init(path: String, defaultConfiguration: Configuration) {
        self.path = path

        defaultConfiguration.position = -1;
        self.configurations.append(defaultConfiguration)
    }

    static func < (lhs: Game, rhs: Game) -> Bool {

        var lTitle: String = lhs.defaultConfiguration().sortTitle
        if lTitle == "" {
            lTitle = lhs.defaultConfiguration().title
        }

        var rTitle: String = rhs.defaultConfiguration().sortTitle
        if rTitle == "" {
            rTitle = rhs.defaultConfiguration().title
        }

        return lTitle < rTitle
    }

    func defaultConfiguration() -> Configuration {
        for config in self.configurations where config.position == -1 {
            return config
        }

        let config: Configuration = Configuration()
        config.title = "Default"
        config.position = -1
        self.configurations.append(config)
        return config
    }
}
