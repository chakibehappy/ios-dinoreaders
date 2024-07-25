import Foundation
import SwiftUI

struct ReadingProfileData: Codable {
    let success: Bool
    let data: [ReadingProfile]
}

struct ReadingProfile: Codable, Identifiable {
    let id: Int
    let profile_id: Int
    var auto_correct_own_story: Bool
    var book_by_reading_level: Bool
    var recommend_by_reading_level: Bool
    var set_limit_time: Bool
    var reading_day: String
    var calculated_by: String
    var reading_time: Int
    let profile: [Profile]
    let book_reading: [BookReading]?
    
    // Custom initializer with default values
    init(id: Int = 0,
         profile_id: Int = 0,
         auto_correct_own_story: Bool = false,
         book_by_reading_level: Bool = false,
         recommend_by_reading_level: Bool = false,
         set_limit_time: Bool = false,
         reading_day: String = "",
         calculated_by: String = "",
         reading_time: Int = 0,
         profile: [Profile] = [],
         book_reading: [BookReading]? = nil) {
        
        self.id = id
        self.profile_id = profile_id
        self.auto_correct_own_story = auto_correct_own_story
        self.book_by_reading_level = book_by_reading_level
        self.recommend_by_reading_level = recommend_by_reading_level
        self.set_limit_time = set_limit_time
        self.reading_day = reading_day
        self.calculated_by = calculated_by
        self.reading_time = reading_time
        self.profile = profile
        self.book_reading = book_reading
    }
}

struct Profile: Codable {
    let name: String
    let img_url: String
    let reading_level: Int
    let grl: String
    let dra: Int
}

struct BookReading: Codable {
    let id: Int
    let cover: String
    let reading_count: Int
    let reading_time: Int
    let reading_score: Int
}
