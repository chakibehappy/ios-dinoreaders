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
    
    init(){
        self.isLoggedIn = false
        self.ReadingLevel = 1
        self.TotalPoints = 0
        self.TotalBooksRead = 0
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
}

class API{
    static var BASE_API = "http://dinoreaders.com/api/"
    static var GETPROFILEINFO_API = BASE_API + "profile/show_info/"
    static var DASHBOARD_API = BASE_API + "dashboard"
    static var OWN_STORY_API = BASE_API + "own-story/all-books/"
    static var PROFILE_API = BASE_API + "profile"
    static var PROFILESETTING_API = BASE_API + "parent-setting/show/"
    static var SAVE_PROFILE_API = BASE_API + "profile/store"
    
    static var GETBOOKBYREADINGLEVEL_API = BASE_API + "publish/book/allByReadingLevel/";
}
