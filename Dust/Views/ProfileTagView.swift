//
//  RetroAchievementsView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-15.
//


import CachedAsyncImage
import SwiftData
import SwiftUI

struct ProfileTagView : View
{
    @Environment(AchievementsManager.self)
    var achievementsManager:AchievementsManager;
    
    var body: some View
    {
        if (self.achievementsManager.signedIn)
        {
            HStack
            {
                UrlImageView(url:self.achievementsManager.displayPictureIUrl ?? "")
                    .frame(width: 22, height: 22)
                
                Text(self.achievementsManager.displayName ?? "");
            }
        }
    }
}
