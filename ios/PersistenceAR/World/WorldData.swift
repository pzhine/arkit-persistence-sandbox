//
//  WorldData.swift
//  WorldAsSupport
//
//  Created by Paul on 10/27/19.
//  Copyright © 2019 UPF. All rights reserved.
//

import Foundation
import ARKit

class WorldData: NSObject, NSCoding, NSSecureCoding {
    var name = ""
    var worldId :String
    var worldMap: ARWorldMap?
    var lastModified :Date?
    var versionId :String?
    
    enum Keys: String {
        case name = "name"
        case worldMap = "worldMap"
        case lastModified = "lastModified"
        case versionId = "versionId"
        case worldId = "worldId"
    }
    
    init(name: String) {
        self.name = name
        self.worldId = MongoID.string(with: MongoID.id())
        super.init()
    }
    
    // MARK: NSCoding Implementation
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: Keys.name.rawValue)
        coder.encode(worldMap, forKey: Keys.worldMap.rawValue)
        coder.encode(lastModified, forKey: Keys.lastModified.rawValue)
        coder.encode(versionId, forKey: Keys.versionId.rawValue)
        coder.encode(worldId, forKey: Keys.worldId.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {
        let name = coder.decodeObject(of: NSString.self, forKey: Keys.name.rawValue) as String? ?? ""
        let lastModified = coder.decodeObject(of: NSDate.self, forKey: Keys.lastModified.rawValue) as Date?
        let versionId = coder.decodeObject(of: NSString.self, forKey: Keys.versionId.rawValue) as String? ?? ""
        let worldId = coder.decodeObject(of: NSString.self, forKey: Keys.worldId.rawValue) as String? ?? ""
        let worldMap = coder.decodeObject(of: ARWorldMap.self, forKey: Keys.worldMap.rawValue) as ARWorldMap?
        
        self.init(name: name)
        self.worldMap = worldMap
        self.lastModified = lastModified
        self.versionId = versionId
        self.worldId = worldId
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
}
