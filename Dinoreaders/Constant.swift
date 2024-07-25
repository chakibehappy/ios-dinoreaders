//
//  Constant.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 19/09/23.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    private let key: String
    private let defaultValue: T
    
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

class UserSettings: ObservableObject {
    @Published var isLoggedIn: Bool {
        didSet{
            UserDefaults.standard.set(isLoggedIn, forKey:"login")
        }
    }
    
    @Published var ReadingLevel: Int {
        didSet{
            UserDefaults.standard.set(ReadingLevel, forKey:"readingLevel")
        }
    }
    
    @Published var TotalPoints: Int {
        didSet{
            UserDefaults.standard.set(TotalPoints, forKey:"totalPoints")
        }
    }
    
    @Published var TotalBooksRead: Int {
        didSet{
            UserDefaults.standard.set(TotalBooksRead, forKey:"totalBooksRead")
        }
    }
    
    @Published var ReadingSetting: ReadingProfile {
        didSet {
            if let encoded = try? JSONEncoder().encode(ReadingSetting) {
                UserDefaults.standard.set(encoded, forKey: "ReadingSetting")
            }
        }
    }
    
    @Published var AvatarIcon: AvatarIconData {
        didSet {
            if let encoded = try? JSONEncoder().encode(AvatarIcon) {
                UserDefaults.standard.set(encoded, forKey: "AvatarIcon")
            }
        }
    }
    
    @Published var AvatarAccessory: AvatarAccessoryData {
        didSet {
            if let encoded = try? JSONEncoder().encode(AvatarAccessory) {
                UserDefaults.standard.set(encoded, forKey: "AvatarAccessory")
            }
        }
    }
    
    @Published var AvatarBackground: AvatarBackgroundData {
        didSet {
            if let encoded = try? JSONEncoder().encode(AvatarBackground) {
                UserDefaults.standard.set(encoded, forKey: "AvatarBackground")
            }
        }
    }
    
    @Published var showDinoEggWindow: Bool  {
        didSet{
            UserDefaults.standard.set(isLoggedIn, forKey:"ShowDinoEggWindow")
        }
    }
    
    init(){
        self.isLoggedIn = false
        self.ReadingLevel = 1
        self.TotalPoints = 0
        self.TotalBooksRead = 0
        
        self.showDinoEggWindow = false
        
        if let profile = UserDefaults.standard.data(forKey: "ReadingSetting"),
           let decoded = try? JSONDecoder().decode(ReadingProfile.self, from: profile) {
            self.ReadingSetting = decoded
        } else {
            self.ReadingSetting = ReadingProfile()
        }
        
        if let savedData = UserDefaults.standard.data(forKey: "AvatarIcon"),
           let decoded = try? JSONDecoder().decode(AvatarIconData.self, from: savedData) {
            self.AvatarIcon = decoded
        } else {
            self.AvatarIcon = AvatarIconData(id: 1, name: "T-Rex", local_path: "", asset_name: "t_rex", img_url: "")
        }
        
        if let acc = UserDefaults.standard.data(forKey: "AvatarAccessory"),
           let decoded = try? JSONDecoder().decode(AvatarAccessoryData.self, from: acc) {
            self.AvatarAccessory = decoded
        } else {
            self.AvatarAccessory = AvatarAccessoryData(id: 1, local_path: "", asset_name: "avatar_frame_1", img_url: "")
        }
        
        if let bg = UserDefaults.standard.data(forKey: "AvatarBackground"),
           let decoded = try? JSONDecoder().decode(AvatarBackgroundData.self, from: bg) {
            self.AvatarBackground = decoded
        } else {
            self.AvatarBackground = AvatarBackgroundData(id: 1, color: "#FFB441", img_url: "")
        }
    }
}

class UserDefaultManager {
    @UserDefault("UserEmail", defaultValue: "")
    static var UserEmail: String
    
    @UserDefault("UserPassword", defaultValue: "")
    static var UserPassword: String
    
    @UserDefault("UserProfilePic", defaultValue: "")
    static var UserProfilePic: String
    
    @UserDefault("UserAccessToken", defaultValue: "")
    static var UserAccessToken: String
    
    @UserDefault("UserID", defaultValue: 0)
    static var UserID: Int
    
    @UserDefault("ProfileID", defaultValue: 0)
    static var ProfileID: Int
    
    @UserDefault("ProfileName", defaultValue: "")
    static var ProfileName: String
}

class API{
    
    static var AWS_PATH = "https://dinoreadersbucket.s3.ap-southeast-1.amazonaws.com"
    
    static var BASE_API = "http://dinoreaders.com/api/"
    static var GETPROFILEINFO_API = BASE_API + "profile/show_info/"
    static var DASHBOARD_API = BASE_API + "dashboard"
    static var OWN_STORY_API = BASE_API + "own-story/all-books/"
    static var PROFILE_API = BASE_API + "profile"
    
    static var PROFILESETTING_API = BASE_API + "parent-setting/show/"
    static var SAVEPROFILESETTING_API = BASE_API + "parent-setting/edit";
    
    static var SAVE_PROFILE_API = BASE_API + "profile/store"
    
    static var GETBOOKBYREADINGLEVEL_API = BASE_API + "publish/book/allByReadingLevel/"
    
    static var GETFAVOURITEBOOK_API = BASE_API + "library"
    static var TOOGLEFAVOURITE_API = BASE_API + "library/favourite"
    
    static var GETALLBOOK_API = BASE_API + "publish/book/all"
    static var GETALLCOLLECTIONS_API = BASE_API + "collections/show-all"
    
    static var GETBOOKDETAIL_API = BASE_API + "book/single/"
    
    static var SAVEREADINGHISTORY_API = BASE_API + "profile-book-reading/store";

    static var GETBOOKQUIZ_API = BASE_API + "book-quiz/view-quiz/";
    
    static var GETDINO_EGG_COLLECTION_API = BASE_API + "dino-eggs-user/all-eggs";
    static var GETDINO_EGG_COUNTER_API = BASE_API + "dino-eggs-user/dino-eggs-user-counter";
    static var DINO_EGG_CHECK_URL = BASE_API + "dino-eggs-user/check-dino-eggs-growth";
    
    static var SAVEPLACEMENTTESTRESULT_API = BASE_API + "placement-test/store";
}

class GradeLabel {
    // Static property to hold the list of grades
    static let listOfGrades: [String] = [
        "Pre-Reading",
        "Early Emergent",
        "Emergent",
        "Early Fluent",
        "Fluent",
        "Advanced Fluent",
        "Proficient",
        "Independent"
    ]
    
    // Static method to get the grade name by index
    static func gradeName(at index: Int) -> String {
        // Ensure the index is within the bounds of the array
        guard index >= 0 && index < listOfGrades.count else {
            return "Invalid Grade"
        }
        return listOfGrades[index]
    }
}

func getFullDayNameInEnglish() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE" // Full day name
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Locale set to English
    
    let currentDate = Date()
    return dateFormatter.string(from: currentDate)
}

func isTodayReadingDay(readingProfile: ReadingProfile) -> Bool {
    if !readingProfile.set_limit_time {
        return true
    }
    let today = getFullDayNameInEnglish().lowercased()
    let lowercasedReadingDay = readingProfile.reading_day.lowercased()
    let days = lowercasedReadingDay.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    return days.contains(today)
}
