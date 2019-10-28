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
    var worldMap: ARWorldMap?
    
    enum Keys: String {
        case name = "name"
        case worldMap = "worldMap"
    }
    
    init(name: String) {
        super.init()
        self.name = name
    }
    
    // MARK: NSCoding Implementation
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: Keys.name.rawValue)
        coder.encode(worldMap, forKey: Keys.worldMap.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {
        let name = coder.decodeObject(of: NSString.self, forKey: Keys.name.rawValue) as String? ?? ""
        let worldMap = coder.decodeObject(of: ARWorldMap.self, forKey: Keys.worldMap.rawValue) as ARWorldMap?
        self.init(name: name)
        self.worldMap = worldMap
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
}
