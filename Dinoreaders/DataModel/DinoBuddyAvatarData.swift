import Foundation

struct AvatarIconData: Codable, Identifiable {
    let id: Int
    let name: String
    let local_path: String
    let asset_name: String
    let img_url:String
}


struct AvatarAccessoryData: Codable, Identifiable {
    let id: Int
    let local_path: String
    let asset_name: String
    let img_url:String
}

struct AvatarBackgroundData: Codable, Identifiable {
    let id: Int
    let color: String
    let img_url:String
}
