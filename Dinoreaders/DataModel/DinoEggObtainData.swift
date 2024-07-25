import Foundation

// Root level
struct DinoEggObtainData: Codable {
    let success: Bool
    let data: [DinoEggObtainDataItem]
}

// Data item
struct DinoEggObtainDataItem: Codable {
    let egg: EggItem
    let dino_egg_data: DinoEggDataItem
}

struct EggItem: Codable {
    let user_id: Int
    let profile_id: Int
    let dino_egg_counter_id: Int
    let dino_egg_id: Int
    let points: Int
    let status: String
    let image_url: String
    let updated_at: String
    let created_at: String
    let id: Int
}

// Dino egg data
struct DinoEggDataItem: Codable {
    let id: Int
    let dino_egg_setting_id: Int
    let dino_name: String
    let egg_image: String
    let baby_dino_image: String
    let adult_dino_image: String
    let created_at: String
    let updated_at: String
    let deleted_at: String?
    let created_by: String?
    let updated_by: String?
    let deleted_by: String?
}

