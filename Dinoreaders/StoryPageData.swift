//
//  StoryPageData.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 24/09/23.
//

import Foundation

struct Line: Codable {
    let left: Double
    let top: Double
    let text: String
    let lineHeight: Double
    let font: String
    let fontSize: Double
    let color: String
}

struct Page: Codable {
    let pageNumber: Int
    let imgUrl: String
    let width: Double
    let height: Double
    let fontSpace: Double
    let lines: [Line]
}

struct StoryPageData: Codable {
    let creator: String
    let pages: [Page]
}

func fetchStoryPageData(from url: URL, completion: @escaping (Result<StoryPageData, Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            let error = NSError(domain: "InvalidData", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        do {
            let bookData = try JSONDecoder().decode(StoryPageData.self, from: data)
            completion(.success(bookData))
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
