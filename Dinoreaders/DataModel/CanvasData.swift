//
//  CanvasData.swift
//  Dinoreaders
//
//  Created by Chaki Behappy on 04/12/23.
//

import Foundation

struct CanvasData: Codable, Identifiable {
    let id: Int
    let name: String
    let thumbnail: String
    let cover: String
}
