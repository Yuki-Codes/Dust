//
//  GamesView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-11.
//

import SwiftUI;
import SwiftData;
import CachedAsyncImage;

struct GamesView: View
{
    var platform:Platform?;
    
    @Environment(\.modelContext)
    private var modelContext;
    
    @Environment(\.colorScheme)
    var colorScheme;
    
    @Query(sort: \Game.title)
    var games: [Game];
    
    @State
    var hover: Game? = nil;
    
    @State
    var background:String = "";
    
    @State
    var nextBackground:String = "";
    
    @State
    var backgroundLoaded:Bool = false;
    
    var coverWidth:Float = 128;
    
    var coverHeight:Float
    {
        return (coverWidth / 9) * 14;
    }
    
    var body: some View
    {
        ZStack
        {
            if (background != "")
            {
                CachedAsyncImage(url: URL(string: background))
                { phase in
                    switch phase
                    {
                    case .success(let image):
                        image.resizable()
                            .onAppear()
                        {
                            self.backgroundLoaded = true;
                        }
                    default:
                        Rectangle();
                    }
                }
                .opacity(self.backgroundLoaded != false ? 1.0 : 0)
                .animation(.easeInOut(duration: 0.25), value: self.backgroundLoaded)
                .ignoresSafeArea()
                .opacity(0.5)
                .padding(-200)
            }
            
            ScrollView
            {
                LazyVGrid(columns: [.init(.adaptive(minimum: CGFloat(coverWidth + 16)))])
                {
                    ForEach(self.games)
                    { game in
                        
                        VStack(alignment: .leading)
                        {
                            ZStack
                            {
                                if (game.coverUrl != nil)
                                {
                                    CachedAsyncImage(url: URL(string: game.coverUrl!))
                                    { phase in
                                        switch phase
                                        {
                                        case .success(let image):
                                            image.resizable();
                                        default:
                                            ProgressView().scaleEffect(0.5);
                                        }
                                    }
                                    .aspectRatio(contentMode: .fit)
                                }
                                else
                                {
                                    Rectangle().background(.thinMaterial);
                                }
                            }
                            .cornerRadius(6)
                            .frame(width: CGFloat(coverWidth), height: CGFloat(coverHeight))
                            .shadow(radius: 6)
                            
                            VStack(alignment: .leading, spacing: 2)
                            {
                                Text(game.title).lineLimit(1);
                                
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
                                    }
                                }
                            }
                        }
                        .frame(width: CGFloat(coverWidth))
                        .padding(.bottom, 16)
                        .onHover
                        { over in
                            if (over)
                            {
                                if (game.coverUrl != nil)
                                {
                                    if (self.background != game.coverUrl!)
                                    {
                                        self.background = game.coverUrl!;
                                        self.backgroundLoaded = false;
                                    }
                                    else
                                    {
                                        self.backgroundLoaded = true;
                                    }
                                }
                                
                                self.hover = game;
                            }
                            else
                            {
                                self.backgroundLoaded = false;
                            }
                        }
                        .contextMenu
                        {
                            Button
                            {
                                Launch(game: game);
                            }
                        label:
                            {
                                Label("Play", systemImage: "play")
                            }
                            
                            Divider();
                            
                            Button
                            {
                                Edit(game:game);
                            }
                        label:
                            {
                                Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                            }
                            
                            Button
                            {
                                OpenDir(game: game);
                            }
                        label:
                            {
                                Label("Open Location", systemImage: "folder")
                            }
                            
                            Divider();
                            
                            Button(role: .destructive)
                            {
                                Delete(game: game);
                            }
                        label:
                            {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(16)
            .padding(.top, 32)
            .background(.regularMaterial)
        }
    }
    
    private func Launch(game:Game)
    {
    }
    
    private func Edit(game:Game)
    {
    }
    
    private func OpenDir(game:Game)
    {
    }
    
    private func Delete(game:Game)
    {
    }
}

#Preview
{
    GamesView()
        .withTestGames()
        .frame(width: 350);
}
