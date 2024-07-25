//
//  DinoEggData.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 22/07/24.
//

import Foundation

struct DinoEggData: Codable {
    var success: Bool
    var data: [DinoEgg]
    
    init(success: Bool = true, data: [DinoEgg] = []) {
        self.success = success
        self.data = data
    }
}


struct DinoEgg: Codable {
    var id: Int
    var dino_egg_id: Int
    var name: String?
    var local_path: String?
    var asset_name: String?
    var image_url: String
    var status: String
    
    init(id: Int, dino_egg_id: Int, name: String, local_path: String, asset_name: String, image_url: String, status: String) {
        self.id = id
        self.dino_egg_id = dino_egg_id
        self.name = name
        self.local_path = local_path
        self.asset_name = asset_name
        self.image_url = image_url
        self.status = status
    }
}
