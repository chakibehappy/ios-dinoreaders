import Foundation

struct SingleBookPage: Codable {
    let id: Int
    let book_id: Int
    let page_number: Int
    let play_audio: Int
    let show_pages: Int
    let page_ref: String
    let thumbnail_ref: String
    let created_at: String
    let updated_at: String
}

struct SingleBook: Codable {
    let id: Int
    let uid: String
    let title: String
    let description: String
    let short_description: String
    let author: String
    let image_url: String
    let pagecount: Int
    let last_read_page: Int?
    let favourite: Bool
    let reading_level: String
    let read_url: String
    let read_to_me: Bool
    let level: [String]
    let categories: [Category]?
    let lang: String
    let published: Int
    let saved: Int
    let pages: [SingleBookPage]
}

struct SingleBookData: Codable {
    let data: SingleBook
}
