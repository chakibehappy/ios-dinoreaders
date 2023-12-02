//
//  SearchTabView.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 18/09/23.
//

import SwiftUI

struct SearchTabView: View {
    var body: some View {
            ZStack{
                Color.yellow
                Image(systemName: "phone.fill")
                    .foregroundColor(Color.white)
                    .font(.system(size: 100.0))
            }
    }
}

struct SearchTabView_Previews: PreviewProvider {
    static var previews: some View {
        SearchTabView()
    }
}
