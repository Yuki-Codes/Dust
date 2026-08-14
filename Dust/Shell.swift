//
//  Shell.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import Foundation;

class Shell
{
    static func Execute(_ command: String)
    {
        print(command);
        
        let task = Process();
        task.arguments = ["-c", command];
        task.launchPath = "/bin/zsh";
        task.standardInput = nil;
        task.launch();
    }
}
