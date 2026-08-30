//
//  GameCoverView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import SwiftUI;
import SwiftData;
import CachedAsyncImage;

struct GameCoverView: View
{
    var game:Game;
    
    var coverWidth:Float;
    
    @State
    var popupOpen:Bool = false;
    
    @State
    var hover:Bool = false;
    
    var coverHeight:Float
    {
        return (coverWidth / 9) * 14;
    }
    
    @Environment(GameManager.self)
    var gameManager:GameManager;
    
    var body: some View
    {
        ZStack
        {
            Rectangle().background(.black).opacity(0.001)
            
            VStack(alignment: .leading)
            {
                ZStack
                {
                    if (game.coverUrl != nil)
                    {
                        UrlImageView(url:game.coverUrl!)
                            .opacity(game.foundInScan ? 1.0 : 0.5)
                    }
                    else
                    {
                        Rectangle().opacity(0).background(.thinMaterial);
                    }
        
                    IconView(iconName:"material-symbols-light:disc-full")
                        .frame(width:48, height:48)
                        .shadow(color: Color.black, radius: 12)
                        .opacity(game.foundInScan ? 0.0 : 1.0)
                }
                .cornerRadius(6)
                .frame(width: CGFloat(coverWidth), height: CGFloat(coverHeight))
                .shadow(radius: 6)
                .shadow(color: .black.opacity(self.hover || self.popupOpen ? 0.5 : 0), radius: 12)
                .scaleEffect(self.hover || self.popupOpen ? 1.05 : 1)
                .animation(.easeInOut(duration: 0.15), value: self.hover)
                
                .popover(isPresented: $popupOpen, arrowEdge: .trailing)
                {
                    GameInfoView(game:game);
                }
                
                VStack(alignment: .leading, spacing: 2)
                {
                    Text(game.title).lineLimit(2);
                    
                    if (game.platform != nil)
                    {
                        HStack(alignment: .center, spacing: 2)
                        {
                            IconView(iconName: game.platform!.iconName)
                                .frame(width:14, height: 14)
                            
                            Text(game.platform!.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1);
                                
                            Spacer();
                                
                            if (game.releaseYear != nil)
                            {
                                Text(game.releaseYear!)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1);
                            }
                        }
                    }
                    
                    Spacer();
                }
            }
        }
        .frame(width: CGFloat(coverWidth))
        .padding(.bottom, 16)
        
        .onHover
        { over in
            
            if(!gameManager.isEditingGame && !gameManager.isPlayingGame)
            {
                self.hover = over;
            }
        }
        .onTapGesture
        {
            self.popupOpen = true;
        }
        
        .contextMenu
        {
            if (game.platform != nil)
            {
                Button
                {
                    gameManager.Launch(game: game);
                }
                label:
                {
                    Label("Play", systemImage: "play")
                }
                
                Divider();
                
                Button
                {
                    gameManager.Edit(game: game);
                }
                label:
                {
                    Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                }
                
                Button
                {
                    gameManager.OpenDir(game: game);
                }
                label:
                {
                    Label("Open Location", systemImage: "folder")
                }
                
                Divider();
            }
            
            if (!game.hidden)
            {
                Button()
                {
                    gameManager.Hide(game: game);
                }
                label:
                {
                    Label("Delete", systemImage: "trash")
                }
            }
            else
            {
                Button()
                {
                    gameManager.UnHide(game: game);
                }
                label:
                {
                    Label("Put Back", systemImage: "trash.slash")
                }
            }
        }
    }
}
