//
//  GameManager.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import SwiftData
import SwiftUI

@Observable
class GameManager
{
    var isEditingGame:Bool = false;
    var editingGame:Game? = nil;
    
    var isPlayingGame:Bool = false;
    var playingGame:Game? = nil;
    
    init()
    {
    }
    
    func Launch(game:Game)
    {
        if (game.platform == nil)
        {
            return;
        }
        
        var proc:Process? = nil;
        
        if (game.platform!.platformType == .Applications)
        {
            proc = Shell.Execute("open -n -W \"\(game.path)\"");
        }
        else if (game.platform!.platformType == .Emulator)
        {
            if (game.platform!.executablePath == "")
            {
                return;
            }
            
            var args = game.platform!.launchArgs;
            
            if (game.customLaunch != nil)
            {
                args = game.customLaunch!;
            }
            
            let fileName = (game.path as NSString).lastPathComponent
                
            args = args.replacingOccurrences(of: "{path}", with: "\"\(game.path)\"");
            args = args.replacingOccurrences(of: "{file}", with: "\"\(fileName)\"");
            args = args.replacingOccurrences(of: "{title}", with: "\"\(game.title)\"");
            
            proc = Shell.Execute("open -n -W \"\(game.platform!.executablePath)\" --args \(args)");
        }
        
        if (proc != nil)
        {
            BeginWatching(game:game, process:proc!);
        }
    }
    
    func Edit(game:Game)
    {
        isEditingGame = true;
        editingGame = game;
    }
    
    func OpenDir(game:Game)
    {
        if (game.platform == nil)
        {
            return;
        }
        
        _ = Shell.Execute("open \(game.platform!.directory)");
    }
    
    func Hide(game:Game)
    {
        game.hidden = true;
    }
    
    func UnHide(game:Game)
    {
        game.hidden = false;
    }
    
    private func BeginWatching(game:Game, process:Process)
    {
        _ = Task
        {
            return await self.Watch(game:game, process:process);
        }
    }
    
    private func Watch(game:Game, process:Process) async
    {
        self.playingGame = game;
        self.isPlayingGame = true;
        
        do
        {
            while(process.isRunning)
            {
                try await Task.sleep(for: .seconds(1));
            }
            
            try await DustApp.AchievementsManager?.UpdateAchievements(game:game);
        }
        catch
        {
            print(error);
        }
        
        self.isPlayingGame = false;
        self.playingGame = nil;
    }
}
