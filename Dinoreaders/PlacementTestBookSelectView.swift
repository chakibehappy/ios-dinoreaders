//
//  PlacementTestBookSelectView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 01/11/23.
//

import SwiftUI

struct PlacementTestBookSelectView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack(){
            Text("Select Book")
           
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear(){
            getBookDataByLevel()
        }
    }
    
    func getBookDataByLevel(){
        guard let url = URL(string: API.GETBOOKBYREADINGLEVEL_API + "1") else {
            return
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaultManager.UserAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
                
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
                if let fullResponse = jsonResponse as? [String : Any]{
                    print(fullResponse)
                }
            }
//            if let data = data {
//                do {
//                    let decodedData = try JSONDecoder().decode(OwnStoryResponseData.self, from: data)
//                    DispatchQueue.main.async {
//                    self.responseData = decodedData
//                    }
//                } catch {
//                    print("Error decoding JSON: \(error)")
//                }
//            }
        }.resume()
    }
}

struct PlacementTestBookSelectView_Previews: PreviewProvider {
    static var previews: some View {
        PlacementTestBookSelectView()
    }
}
