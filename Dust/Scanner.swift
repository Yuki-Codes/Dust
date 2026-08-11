//
//  Scanner.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-11.
//

import SwiftData
import SwiftUI

@Observable
class Scanner
{
    var isScanning:Bool = false;
    var status:String = "Initializing...";
    
    func BeginScan()
    {
        _ = Task
        {
            return await self.ScanSafe();
        }
    }
    
    private func ScanSafe() async
    {
        if (self.isScanning)
        {
            return;
        }
        
        self.isScanning = true;
        do
        {
            try await self.Scan();
        }
        catch
        {
            print(error);
        }
        
        self.isScanning = false;
    }
    
    private func Scan() async throws
    {
        
        
        self.status = "Waiting..."
        try await Task.sleep(for: .seconds(1));
        self.status = "Waiting...1"
        try await Task.sleep(for: .seconds(1));
        self.status = "Waiting...2"
        try await Task.sleep(for: .seconds(1));
        self.status = "Waiting...3"
        try await Task.sleep(for: .seconds(1));
        self.status = "Waiting...4"
        try await Task.sleep(for: .seconds(1));
    }
    
    private func Scan(platform:Platform) async throws
    {
        let url:URL = URL(filePath: platform.directory);
        if (!url.startAccessingSecurityScopedResource())
        {
            print("Failed to get security scoped resource for path: \(url.absoluteString)");
            return;
        }
        
        do
        {
            let files:[String] = try FileManager.default.contentsOfDirectory(atPath: platform.directory);
            let pattern = try Regex(platform.searchPattern);
            
            for file in files
            {
                if (file.contains(pattern))
                {
                    await Scan(platform:platform, file:file);
                }
            }
        }
        catch
        {
            print("error: \(error)");
        }
        
        url.stopAccessingSecurityScopedResource();
    }
    
    private func Scan(platform:Platform, file:String) async
    {
        print(file);
    }
}

extension EnvironmentValues
{
    @Entry
    var scanner: Scanner = Scanner();
}
