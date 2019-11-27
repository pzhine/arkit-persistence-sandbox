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
    
    // MARK: Api Client
    
    static func updateFromCloud(localWorldDocs: [WorldDoc], onComplete complete: @escaping (_ apiResponse: ApiResponse, _ worldDocs: [WorldDoc]?) -> Void) {
        // get fresh list of API Worlds from the server
        let request = ApiClient.makeApiRequest(path: "worlds", verb: "GET")
        ApiClient.dataTask(request: request) { (apiResponse) in
            if let error = apiResponse.error {
                // error
                print("updateFromCloud: error", error)
                complete(apiResponse, nil)
                return
            }
            // success
            guard let apiWorlds = apiResponse.worlds else {
                fatalError("response is missing worlds array")
            }
            // loop over ApiWorlds in response and compare to corresponding WorldDoc in localWorldDocs
            let updatedLocalWorldDocs = apiWorlds.map { apiWorld -> WorldDoc in
                // find WorldDoc with corresponding ID
                var localWorldDoc = localWorldDocs.first { worldDoc in
                    return worldDoc.data?.worldId == apiWorld._id
                }
                // if not found, create it
                if (localWorldDoc == nil) {
                    localWorldDoc = WorldDoc(name: apiWorld.name)
                    localWorldDoc!.data!.worldId = apiWorld._id
                }
                // update current version and flag for update
                localWorldDoc!.data!.versionId = apiWorld.currentVersion
                localWorldDoc!.data!.needsUpdate = true
                localWorldDoc!.saveData()
                return localWorldDoc!
            }
            complete(apiResponse, updatedLocalWorldDocs)
        }
    }
}
