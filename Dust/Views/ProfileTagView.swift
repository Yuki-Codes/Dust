//
//  RetroAchievementsView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-15.
//


import CachedAsyncImage
import SwiftData
import SwiftUI

struct ProfileView : View
{
    @Environment(AchievementsManager.self)
    var achievementsManager:AchievementsManager;
    
    var body: some View
    {
        if (self.achievementsManager.signedIn)
        {
            HStack
            {
                UrlImageView(url:self.achievementsManager.displayPictureIUrl);
                Text(self.achievementsManager.displayName);
            }
        }
    }
}
