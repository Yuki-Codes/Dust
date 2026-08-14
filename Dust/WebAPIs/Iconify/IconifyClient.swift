//
//  IconifyClient.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import System;
import Foundation;
import SwiftData;
import SwiftUI;

class IconifyClient
{
    let baseAddress:String = "https://api.iconify.design/";
    let session:URLSession;
    
    init()
    {
        let config:URLSessionConfiguration = URLSessionConfiguration.default;
        self.session = URLSession(configuration: config);
    }
    
    func Search(term:String) async throws -> [String]?
    {
        let escapedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed);
        if (escapedTerm == nil)
        {
            return nil;
        }
        
        let response:IconifySearchResponse? = try await Get(uri: "search?query=\(escapedTerm!)&pretty=1");
        return response?.icons;
    }
    
    func GetIconUrl(name:String) -> URL?
    {
        return URL(string:"\(baseAddress)\(name).svg");
    }
    
    private func Get<T : Decodable>(uri:String) async throws -> T?
    {
        guard let url = URL(string: "\(self.baseAddress)\(uri)") else
        {
            return nil;
        }
        
        let (data, _) = try await self.session.data(from: url);
        return try JSONDecoder().decode(T.self, from: data);
    }
}

struct IconifySearchResponse : Decodable
{
    var icons:[String]
}
