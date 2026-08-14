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
    
    var coverHeight:Float
    {
        return (coverWidth / 9) * 14;
    }
    
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
        }
        .frame(width: CGFloat(coverWidth))
        .padding(.bottom, 16)
        
        .onHover
        { over in
            popupOpen = over;
        }
        
        .popover(isPresented: $popupOpen, arrowEdge: .trailing)
        {
            VStack
            {
                if (game.logoUrl != nil)
                {
                    CachedAsyncImage(url: URL(string: game.logoUrl!))
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
                    .frame(height: 100)
                }
                else
                {
                    Text(game.title).font(.title);
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
                /*.padding(.bottom, 16)
                
                Text(game.file)
                    .font(.footnote)
                    .foregroundStyle(.secondary);*/
            }
            .padding(8)
            .frame(width:300);
        }
        
        .contextMenu
        {
            if (game.platform != nil)
            {
                Button
                {
                    Launch();
                }
            label:
                {
                    Label("Play", systemImage: "play")
                }
                
                Divider();
                
                Button
                {
                    Edit();
                }
            label:
                {
                    Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                }
                
                Button
                {
                    OpenDir();
                }
            label:
                {
                    Label("Open Location", systemImage: "folder")
                }
                
                Divider();
            }
            
            Button(role: .destructive)
            {
                Delete();
            }
        label:
            {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func Launch()
    {
        if (game.platform == nil)
        {
            return;
        }
        
        if (game.platform!.platformType == .Applications)
        {
            let path = "\(game.platform!.directory)\(game.file)";
            Shell.Execute("open \(path)");
        }
        else if (game.platform!.platformType == .Emulator)
        {
            if (game.platform!.executablePath == "")
            {
                return;
            }
            
            var args = game.platform!.launchArgs;
            args = args.replacingOccurrences(of: "{path}", with: "\(game.platform!.directory)\(game.file)");
            args = args.replacingOccurrences(of: "{file}", with: game.file);
            args = args.replacingOccurrences(of: "{title}", with: game.title);
            
            print(args);
            
            Shell.Execute("open \(game.platform!.executablePath) --args \(args)");
        }
    }
    
    private func Edit()
    {
    }
    
    private func OpenDir()
    {
        if (game.platform == nil)
        {
            return;
        }
        
        Shell.Execute("open \(game.platform!.directory)");
    }
    
    private func Delete()
    {
    }
}
