import Foundation



class WordManager {
    static let shared = WordManager()
    
    private(set) var words: [String] = []

    private init() {
        loadWords()
    }
    
    func loadWords() {
        guard let fileURL = Bundle.main.url(forResource: "english_word_db", withExtension: "txt") else {
            print("File not found")
            return
        }
        
        do {
            let fileContent = try String(contentsOf: fileURL)
            //print("File Content:\n\(fileContent)") // Debug print

            // Split content by new lines and map to uppercase words
            
            words = fileContent
                .components(separatedBy: CharacterSet.newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
            
            print("Total words loaded: \(words.count)") // Print total number of words
            
        } catch {
            print("Error reading file: \(error)")
        }
    }
    
    func wordExists(_ word: String) -> Bool {
        return words.contains(cleanString(word).uppercased())
    }
}


func wordCount(from sentence: String) -> Int {
    let punctuationSet = CharacterSet(charactersIn: ",.!?")
    let words = sentence
        .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(punctuationSet))
        .filter { !$0.isEmpty } // Remove empty strings
    
    return words.count
}

func wordDictionaryCount(from sentence: String) -> Int {
    var count = 0
    let punctuationSet = CharacterSet(charactersIn: ",.!?")
    let words = sentence
        .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(punctuationSet))
        .filter { !$0.isEmpty } // Remove empty strings
    
    for word in words{
        if(!WordManager.shared.wordExists(word)){
            //print(word)
            continue
        }
        count += 1
    }
    return count
}

func cleanString(_ input: String) -> String {
    // Define the character sets to remove
    let punctuationCharacterSet = CharacterSet.punctuationCharacters
    let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines

    // Remove punctuation characters
    let stringWithoutPunctuation = input.components(separatedBy: punctuationCharacterSet).joined()
    
    // Trim leading and trailing whitespace and remove extra spaces
    let trimmedAndCleanedString = stringWithoutPunctuation
        .trimmingCharacters(in: whitespaceCharacterSet) // Remove leading and trailing whitespace
        .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // Replace multiple spaces with a single space
    
    return trimmedAndCleanedString
}
