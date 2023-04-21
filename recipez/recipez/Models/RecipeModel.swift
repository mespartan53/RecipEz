//
//  RecipeModel.swift
//  recipez
//
//  Created by Marcus Estrada on 4/21/23.
//

import Foundation


struct RecipeModel: Codable {
    var title: String
    var photoUrl: String
    var tags: [String]
    var isBeverage: Bool
    var directions: [String]
    var ingredients: [String]
    var ingredientAmounts: [String]
    var ingredientUnits: [String]
    var createdDate: Date
    var createdByName: String
    var createdBy: String
    var totalServings: String?
    var calories: Int?
    var notes: String?
}
