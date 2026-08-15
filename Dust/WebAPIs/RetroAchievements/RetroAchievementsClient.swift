//
//  RetroAchievementsClient.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-15.
//

import System;
import Foundation;
import SwiftData;
import SwiftUI;

class RetroAchievementsClient : Observable
{
    public var connected:Bool = false;
    
    private let baseAddress:String = "https://retroachievements.org/API/";
    private var apiKey:String? = nil;
    private var userName:String? = nil;
    private var session:URLSession? = nil;
    
    init()
    {
        let storage = UserDefaults();
        self.apiKey = storage.string(forKey: "raApiKey");
        self.userName = storage.string(forKey: "raUserName");
        
        if (self.apiKey != nil)
        {
            let config:URLSessionConfiguration = URLSessionConfiguration.default;
            self.session = URLSession(configuration: config);
            self.connected = true;
        }
    }
    
    public func GetUserProfile(name:String? = nil) async throws -> UserProfile?
    {
        var userName = name;
        if (userName == nil)
        {
            userName = self.userName;
        }
        
        if (userName == nil)
        {
            return nil;
        }
        
        return try await Get(uri: "API_GetUserProfile",
            args: [
                "u": userName!
            ]);
    }
    
    class UserProfile : Decodable
    {
        var User:String;
        var ULID:String;
        var UserPic:String?;
        var RichPresenceMsg:String?;
        var LastGameId:Int?;
        var TotalPoints:Int = 0;
        var TotalSoftcorePoints:Int = 0;
        var TotalTruePoints:Int = 0;
    }
    
    public func GetMediaUrl(uri:String) -> String
    {
        return "https://media.retroachievements.org\(uri)";
    }
    
    private func Get<T:Decodable>(uri:String, args:Dictionary<String, String>) async throws -> T?
    {
        if (self.session == nil)
        {
            return nil;
        }
        
        var urlStr:String = "\(self.baseAddress)\(uri).php?y=\(self.apiKey!)";
        
        for (key, value) in args
        {
            urlStr.append("&\(key)=\(value)");
        }
        
        guard let url = URL(string: urlStr) else
        {
            return nil;
        }
        
        let (data, _) = try await self.session!.data(from: url);
        
        let decoder = JSONDecoder();
        decoder.dateDecodingStrategy = .secondsSince1970;
        
        let result = try decoder.decode(T.self, from: data);
        return result;
    }
}
