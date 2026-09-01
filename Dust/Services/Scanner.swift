//
//  Scanner.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-11.
//

import SwiftData
import SwiftUI

@Observable
class Scanner {
    var isScanning: Bool = false
    var status: String = "Initializing..."

    func beginScan() {
        _ = Task {
            return await self.scanSafe()
        }
    }

    private func scanSafe() async {
        if self.isScanning {
            return
        }

        self.isScanning = true
        do {
            try await self.scan()
        } catch {
            print(error)
        }

        self.isScanning = false
    }

    private func scan() async throws {
        let games: [Game] = try Services.Container.mainContext.fetch(FetchDescriptor<Game>())
        for game in games {
            game.foundInScan = false
        }

        let platforms: [Platform] = try Services.Container.mainContext.fetch(FetchDescriptor<Platform>())

        for platform in platforms {
            try await self.scan(platform: platform)
        }

        self.status = "Done"
        try await Task.sleep(for: .seconds(1))
    }

    private func scan(platform: Platform) async throws {
        self.status = platform.name

        print(platform.name)

        for directory in platform.directories {
            let url: URL = URL(filePath: directory)
            if !url.startAccessingSecurityScopedResource() {
                print("Failed to get security scoped resource for path: \(url.absoluteString)")
                return
            }

            do {
                try await self.scan(platform: platform, dir: directory)
            } catch {
                print("error: \(error)")
            }

            url.stopAccessingSecurityScopedResource()
        }
    }

    private func scan(platform: Platform, dir: String) async throws {
        let files: [String] = try FileManager.default.contentsOfDirectory(atPath: dir)
        let pattern = try Regex(platform.searchPattern)

        for file in files {
            var path: String = dir
            if !path.hasSuffix("/") && !file.hasPrefix("/") {
                path = path.appending("/")
            }

            path = path.appending(file)

            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: path, isDirectory: &isDir)

            if file.contains(pattern) {
                try await self.scan(platform: platform, path: path)
            } else if isDir.boolValue {
                try await self.scan(platform: platform, dir: path)
            }
        }
    }

    private func scan(platform: Platform, path: String) async throws {
        let fileName = (path as NSString).lastPathComponent

        self.status = "\(platform.name) - \(fileName)"

        // not ideal, but fast enough for now.
        let games: [Game] = try Services.Container.mainContext.fetch(FetchDescriptor<Game>())
        var game: Game?
        for existingGame in games where existingGame.path == path {
            game = existingGame
            break
        }

        // Try get SGDB game
        if game == nil && Services.SgdbClient.connected {
            let results = try await Services.SgdbClient.search(term: fileName)

            if results != nil && !results!.isEmpty {
                let sgdbGame = results![0]
                print("Found: \"\(sgdbGame.name)\" for \"\(fileName)\"")

                let config: Configuration = Configuration()
                await Services.SgdbClient.importMetadata(sgdbGame: sgdbGame, config: config)

                game = Game(path: path, defaultConfiguration: config)
                game!.platform = platform

                // save
                Services.Container.mainContext.insert(game!)
            }
        }

        // fallback to direct game
        if game == nil {

            var config: Configuration = Configuration()
            config.title = fileName

            game = Game(path: path, defaultConfiguration: config)
            game!.platform = platform
        }

        if game != nil {
            game?.foundInScan = true
        }
    }
}
