//
//  StoryPageData.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 24/09/23.
//

import Foundation

struct Line: Codable, Hashable {
    let left: Double
    let top: Double
    let text: String
    let lineHeight: Double
    let font: String
    let fontSize: Double
    let color: String
    
    func compareTo(_ other: Line) -> ComparisonResult {
        let topComparison = self.top.compare(other.top)

        if (self.top - other.top <= self.lineHeight / 2) && (self.top - other.top > -self.lineHeight / 2) {
            return self.left.compare(other.left)
        }
        return topComparison
    }
}

extension Double {
    func compare(_ other: Double) -> ComparisonResult {
        if self < other {
            return .orderedAscending
        } else if self > other {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }
}

struct Page: Codable {
    let pageNumber: Int
    let imgUrl: String
    let width: Double
    let height: Double
    let fontSpace: Double
    var lines: [Line]
    var isStoryPage: Bool?
    var playAudio: Bool?
    var fullText: String?
}

struct StoryPageData: Codable {
    let creator: String
    var pages: [Page]
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

func processPages(_ bookData: StoryPageData) -> StoryPageData {
    var processedBookData = bookData

    for i in 0..<processedBookData.pages.count {
        var page = processedBookData.pages[i]
        let originalLines = page.lines

        if !originalLines.isEmpty {
            // Sort lines using custom comparison logic
            page.lines.sort { $0.compareTo($1) == .orderedAscending }

            // Find the first order
            if let firstText = page.lines.first?.text,
                var firstOrder = originalLines.firstIndex(where: { $0.text == firstText }) {

                if firstOrder != 0 {
                    var j = 0
                    for line in originalLines{
                        if originalLines[firstOrder].left > line.left + page.width/8{
                            firstOrder = j
                            break
                        }
                        j += 1
                    }
                    // Reorder lines based on the first order
                    let reorderedLines = Array(originalLines[firstOrder...]) + Array(originalLines[..<firstOrder])
                    page.lines = reorderedLines
                    
                    //print(originalLines[0].text)
                    
                } else {
                    // make sure the first lines is most left! (since we simply using original lines here)
                    // add width of the page on our formula to make sure line is really far 1/8 width
                    var j = 0
                    for line in page.lines{
                        if originalLines[firstOrder].left > line.left + page.width/8{
                            firstOrder = j
                            break
                        }
                        j += 1
                    }
                    
                    if(firstOrder != 0){
                        let reorderedLines = Array(originalLines[firstOrder...]) + Array(originalLines[..<firstOrder])
                        page.lines = reorderedLines
                    }
                    else{
                        if originalLines != page.lines {
                            page.lines = originalLines
                        }
                    }
                }
                
            }

            // Constructing fullText based on lines
            var fullText = ""
            for (index, line) in page.lines.enumerated() {
                var isAddingText = true
                if wordCount(from: line.text) == 1 {
                    isAddingText = WordManager.shared.wordExists(line.text)
                }
                if !isAddingText{
                    continue
                }
                    
                fullText += line.text
                if index < page.lines.count - 1 {
                    fullText += " "
                }
            }
            fullText = fullText.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            page.fullText = fullText
            //print(fullText)
        }

        processedBookData.pages[i] = page
    }

    return processedBookData
}
