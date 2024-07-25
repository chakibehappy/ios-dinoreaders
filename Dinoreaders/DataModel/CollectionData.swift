import SwiftUI

struct CollectionResponse: Codable {
    let data: [Collection]
}

struct Collection: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let visibility: Int
    let status: Int
    let created_at: String?
    let dateO_of_creation: String?
    let created_by: Int?
    let created_by_user: String?
    let shortDescription: String?
    let books: [CollectionBook]
    let collection_books: [CollectionBookID]
    let organization: [String] // Adjust the type based on the actual data
    let profiles: CollectionProfile?
}

struct CollectionBook: Codable, Identifiable {
    let id: Int
    let author: String
    let title: String
    let lang: String
    let description: String?
    let read_url: String?
    let image_url: String
}

struct CollectionBookID: Codable, Identifiable {
    let id: Int?
    let collection_id: Int?
    let book_id: Int?
}

struct CollectionProfile: Codable, Identifiable {
    let id: Int?
    let name: String?
    let img_url: String?
    let dob: String?
    let reading_level: Int?
    let grl: String?
    let dra: Int?
    let max_created_story: Int?
    let created_at: String?
    let updated_at: String?
    let deleted_at: String?
    let created_by: Int?
    let updated_by: Int?
    let deleted_by: Int?
    let pivot: Pivot
}

struct Pivot: Codable {
    let collection_id: Int
    let profile_id: Int
}
