//
//  IconifyClient.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import System
import Foundation
import SwiftData
import SwiftUI

class IconifyClient: Observable {
    let baseAddress: String = "https://api.iconify.design/"
    let session: URLSession

    init() {
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
    }

    func search(term: String) async throws -> [String]? {
        let escapedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if escapedTerm == nil {
            return nil
        }

        let response: IconifySearchResponse? = try await self.get(uri: "search?query=\(escapedTerm!)&pretty=1")
        return response?.icons
    }

    func getIconUrl(name: String) -> URL? {
        return URL(string: "\(self.baseAddress)\(name).svg")
    }

    private func get<T: Decodable>(uri: String) async throws -> T? {
        guard let url = URL(string: "\(self.baseAddress)\(uri)") else {
            return nil
        }

        let (data, _) = try await self.session.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

struct IconifySearchResponse: Decodable {
    var icons: [String]
}
