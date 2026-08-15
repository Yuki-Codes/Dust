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
            let raProfile = try await DustApp.RetroAchievementsClient?.GetUserProfile();
            
            if (raProfile != nil)
            {
                self.signedIn = true;
                self.displayName = raProfile!.User;
                
                if (raProfile!.UserPic != nil)
                {
                    self.displayPictureIUrl = DustApp.RetroAchievementsClient?.GetMediaUrl(uri: raProfile!.UserPic!);
                }
            }
        }
        catch
        {
            print(error);
        }
    }
    
    func UpdateAchievements(game:Game) async throws
    {
        
    }
}
