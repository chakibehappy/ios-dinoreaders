import Foundation

struct GradeBookData: Codable {
    var success: Bool
    var data: [GradeBook]
    
    init(success: Bool = true, data: [GradeBook] = []) {
        self.success = success
        self.data = data
    }
}


struct GradeBook:  Codable {
    var author: String
    var description: String
    var id: Int
    var image_url: String
    var lang: String
    var reading_level: String
    var title: String
    var uid: String
}
