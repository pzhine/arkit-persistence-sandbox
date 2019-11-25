//
//  WorldDatabase.swift
//  WorldAsSupport
//
//  Created by Paul on 10/27/19.
//  Copyright © 2019 UPF. All rights reserved.
//

import Foundation

class WorldDatabase: NSObject {
    private static let EXT = "wasworld"
    
    static let privateDocsDir: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectoryURL = paths.first!.appendingPathComponent("PrivateDocuments")
      
        do {
            try FileManager.default.createDirectory(at: documentsDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Couldn't create directory: " + error.localizedDescription)
        }
        print(documentsDirectoryURL.absoluteString)
        return documentsDirectoryURL
    }()
    
    static func nextWorldDocPath() -> URL? {
        // 1) Get all the files and folders within the database folder
        guard let files = try? FileManager.default.contentsOfDirectory(at: privateDocsDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return nil }
        var maxNumber = 0
      
        // 2) Get the highest numbered item saved within the database
        files.forEach {
            if $0.pathExtension == EXT {
                let fileName = $0.deletingPathExtension().lastPathComponent
                maxNumber = max(maxNumber, Int(fileName) ?? 0)
            }
        }
      
        // 3) Return a path with the consecutive number
        return makeWorldDocPath(from: String(maxNumber + 1))
    }
    
    static func makeWorldDocPath(from name: String) -> URL {
        return privateDocsDir.appendingPathComponent("\(name).\(EXT)", isDirectory: true)
    }
    
    static func loadWorldDocs() -> [WorldDoc] {
        guard let files = try? FileManager.default.contentsOfDirectory(at: privateDocsDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return [] }
      
        return files
            .filter { $0.pathExtension == EXT }
            .map { WorldDoc(docPath: $0) }
    }
}
