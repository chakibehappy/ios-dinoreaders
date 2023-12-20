//
//  LibraryResponseData.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 05/12/23.
//

import Foundation


struct LibraryResponseData: Codable {
    let success: Bool
    let data: [LibraryItem]
}

struct LibraryItem: Codable {
    let name: String
    let type: String
    let item_type: String
    let title_icon: String
    let content: [LibraryContentItem]?
}

struct LibraryContentItem: Codable {
    let id: Int
    let uid: String?
    let title: String?
    let description: String?
    let short_description: String?
    let author: String?
    let image_url: String?
    let pagecount: Int?
    let last_read_page: Int?
    var favourite: Bool?
    let reading_level: String?
    let read_url: String?
    let read_to_me: Bool?
    let level: [AgeLevel]?
    let categories: [Category]?
    let lang: String?
    let published: Int?
    let saved: Int?
    let pages: [LibraryPageItem]?
    let is_own_story: Bool?
}

struct LibraryPageItem: Codable, Hashable {
    let id: Int?
    let book_id: Int?
    let page_number: Int?
    let play_audio: Int?
    let show_pages: Int?
    let page_ref: String?
    let thumbnail_ref: String?
    let created_at: String?
    let updated_at: String?
}
