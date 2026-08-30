//
//  GameInfoView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-15.
//

import SwiftUI;
import SwiftData;
import CachedAsyncImage;

struct GameInfoView: View
{
    var game:Game;
    
    @Environment(GameManager.self)
    var gameManager:GameManager;
    
    var body: some View
    {
        VStack
        {
            if (game.logoUrl != nil)
            {
                UrlImageView(url: game.logoUrl!)
                    .frame(maxHeight: 100)
                    .padding(.horizontal, 16)
                    .padding(.top, 16);
            }
            else
            {
                Text(game.title)
                    .font(.title)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6);
            }
            
            HStack
            {
                if (game.releaseYear != nil)
                {
                    Text(game.releaseYear!);
                }
                
                if(game.platform != nil)
                {
                    IconView(iconName: game.platform!.iconName)
                        .frame(width:18, height: 18);
                    
                    Text(game.platform!.name);
                }
            }
            .padding(.bottom, 16)
            
            if (game.achievmentCount > 0)
            {
                HStack
                {
                    Image(systemName: "trophy.fill")
                        .frame(width: 20, height: 20);
                    
                    Text("\(game.earnedAchievements) of \(game.achievmentCount)");
                    
                    ProgressView(value: game.achievementProgress)
                }
                .padding(.horizontal, 16);
                
                ScrollView
                {
                    VStack(alignment: .leading)
                    {
                        Rectangle().opacity(0).frame(height: 0);
                        
                        ForEach(game.achievements.sorted())
                        { achievement in
                            
                            if (achievement.earned != nil)
                            {
                                HStack
                                {
                                    if (achievement.imageUrl != nil)
                                    {
                                        UrlImageView(url: achievement.imageUrl!)
                                            .frame(width: 42, height:42);
                                    }
                                    
                                    VStack(alignment: .leading)
                                    {
                                        Text(achievement.title)
                                            .lineLimit(1);
                                        
                                        Text(achievement.body ?? "")
                                            .font(.caption)
                                            .lineLimit(2)
                                            .foregroundStyle(.secondary);
                                        
                                        Text("Earned \(achievement.earned!.formatted())")
                                            .font(.caption)
                                            .lineLimit(1)
                                            .foregroundStyle(.secondary);
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Divider()
                        .padding(.horizontal, 32);
                    
                    VStack(alignment: .leading)
                    {
                        ForEach(game.achievements.sorted())
                        { achievement in
                            
                            if (achievement.earned == nil)
                            {
                                HStack
                                {
                                    if (achievement.imageUrl != nil)
                                    {
                                        UrlImageView(url: achievement.imageUrl!)
                                            .frame(width: 32, height:32)
                                            .blur(radius: 1)
                                            .opacity(0.75)
                                    }
                                    
                                    VStack(alignment: .leading)
                                    {
                                        Text(achievement.title)
                                            .lineLimit(1)
                                            .foregroundStyle(.secondary)
                                        
                                        Text(achievement.body ?? "")
                                            .font(.caption)
                                            .lineLimit(2)
                                            .foregroundStyle(.tertiary);
                                    }
                                }
                            }
                        }
                        
                        Rectangle().opacity(0).frame(height: 0);
                    }
                    .padding(.horizontal, 16);
                }
                .frame(maxHeight: 300);
            }
            
            HStack
            {
                Rectangle().opacity(0).frame(height: 2);
                
                Button(action:
                {
                    gameManager.Launch(game: self.game);
                })
                {
                    HStack
                    {
                        Image(systemName: "play.fill");
                        Text("Play");
                    }
                    .padding(6)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(.borderedProminent)
                .padding(16);
            }
        }
        .frame(width:300)
    }
}
