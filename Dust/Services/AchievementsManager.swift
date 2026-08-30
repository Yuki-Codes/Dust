//
//  RetroAchievementsManager.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-15.
//

import SwiftData
import SwiftUI

@Observable
class AchievementsManager
{
    var signedIn:Bool = false;
    
    var displayName:String? = nil;
    var displayPictureIUrl:String? = nil;
    
    private var raProfile:RetroAchievementsClient.UserProfile? = nil;
    
    init()
    {
        BeginSignIn();
    }
    
    func BeginSignIn()
    {
        _ = Task
        {
            return await self.SignIn();
        }
    }
    
    func SignIn() async
    {
        do
        {
            self.raProfile = try await Services.RetroAchievementsClient.GetUserProfile();
            
            if (self.raProfile != nil)
            {
                self.signedIn = true;
                self.displayName = raProfile!.User;
                
                if (self.raProfile!.UserPic != nil)
                {
                    self.displayPictureIUrl = Services.RetroAchievementsClient.GetMediaUrl(uri: self.raProfile!.UserPic!);
                }
            }
        }
        catch
        {
            print(error);
        }
    }
    
    func BeginUpdateAchievments(game:Game)
    {
        _ = Task
        {
            do
            {
                return try await self.UpdateAchievements(game:game);
            }
            catch
            {
                print(error);
            }
        }
    }
    
    func UpdateAchievements(game:Game) async throws
    {
        if (self.raProfile == nil)
        {
            return;
        }
        
        if (game.raId == -1)
        {
            game.achievements.removeAll();
        }
        
        if (self.raProfile != nil && game.raId != nil && game.raId != -1)
        {
            let progress = try await Services.RetroAchievementsClient.GetGameInfoAndUserProgress(ulid: self.raProfile!.ULID, gameId: game.raId!);
            
            if (progress != nil)
            {
                for (key, raAchievement) in progress!.Achievements!
                {
                    var achievement = game.GetAchievement(raId: raAchievement.ID);
                    
                    // Create this RA Achievement locally.
                    if (achievement == nil)
                    {
                        achievement = Achievement(raId: raAchievement.ID);
                        game.achievements.append(achievement!);
                    }
                    
                    achievement?.sortOrder = key;
                    
                    if (achievement!.title == "")
                    {
                        achievement!.title = raAchievement.Title;
                    }
                    
                    if (achievement!.body == nil)
                    {
                        achievement!.body = raAchievement.Description;
                    }
                    
                    if (achievement!.imageUrl == nil && raAchievement.BadgeName != nil)
                    {
                        let badgeUrl:String = "/Badge/\(raAchievement.BadgeName!).png";
                        achievement!.imageUrl = Services.RetroAchievementsClient.GetMediaUrl(uri: badgeUrl);
                    }
                    
                    if (raAchievement.DateEarned != nil)
                    {
                        achievement?.earned = raAchievement.DateEarned;
                    }
                }
            }
        }
    }
}
