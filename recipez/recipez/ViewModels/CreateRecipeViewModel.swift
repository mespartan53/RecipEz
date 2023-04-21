//
//  CreateRecipeViewModel.swift
//  recipez
//
//  Created by Marcus Estrada on 4/3/23.
//

import Foundation
import SwiftUI
import UIKit
import PhotosUI

import Firebase
import FirebaseAuth
import FirebaseStorage

class CreateRecipeViewModel: ObservableObject {
    @Published var image: UIImage?
    
    @Published var title = ""
    @Published var ingredients: [CreatingIngredient]
    @Published var selectedRecipeType = "Food"
    @Published var directions: [(id: UUID, value: String)]
    @Published var tags: [String]
    @Published var servings: String = ""
    @Published var calsPerServing: String = ""
    @Published var recommendations: String = ""
    
    @Published var showLoading = false
    @Published var loading = true
    
    @Published var showAlert = false
    var errorHeading = ""
    var errorBody = ""
    var errorBtn = ""
    
    @Published var recipeDidAddToDB = false
    
    var isBeverage: Bool {
        return self.selectedRecipeType == "Beverage"
    }
    
    var dataAsRecipe: [String: Any] {
        guard let uid = Auth.auth().currentUser?.uid else {
            return ["": ""]
        }
        
        let userRef = Firestore.firestore().collection("users").document(uid)
        var name: String = ""
        
        userRef.getDocument { doc, error in
            if let error = error {
                print(error)
                return
            }
            
            if let doc = doc, doc.exists {
                let data = doc.data()
                if let data = data {
                    name = data["name"] as? String ?? ""
                }
            }
        }
                
        return [
            "title": self.title,
            "tags": self.tags,
            "isBeverage": self.isBeverage,
            "directions": self.directions.map {$0.value},
            "ingredients": self.ingredients.map {$0.title},
            "ingredientAmounts": self.ingredients.map {$0.amount},
            "ingredientUnits": self.ingredients.map {$0.unit},
            "createdDate": Date(),
            "createdByName": name,
            "createdBy": uid,
            "totalServings": self.servings,
            "calories": self.calsPerServing,
            "notes": self.recommendations,
        ]
    }
    
    let recipeTypes = ["Food", "Beverage"]
    
    init() {
        ingredients = [CreatingIngredient(id: UUID())]
        directions = [(id: UUID(), value: "")]
        tags = []
    }
    
    //MARK: Database Funcs
    func validateRecipe() -> Bool {
        if title == "" {
            self.updateError(title: "Error Saving Recipe", body: "Looks like your recipe needs a title", buttonText: nil)
        }
        if image == nil {
            self.updateError(title: "Error Saving Recipe", body: "Don't be a afraid to show off a photo of your recipe", buttonText: nil)
        }
        ingredients.forEach { ingredient in
            if ingredient.title == "" || ingredient.amount == "" {
                self.updateError(title: "Error Saving Recipe", body: "Looks like an ingredient may be missing a name or amount", buttonText: nil)
            }
        }
        directions.forEach { direction in
            if direction.value == "" {
                self.updateError(title: "Error Saving Recipe", body: "One of your directions may be missing", buttonText: nil)
            }
        }
        if tags.count < 1 {
            self.updateError(title: "Error Saving Recipe", body: "Dont forget to add at least one tag", buttonText: nil)
        }
        return !showAlert
    }
    
    func commitImageToDB() async {
        
        var photoUrl: String = ""
        
        withAnimation {
            self.showLoading = true
        }
        
        guard let imageData = self.image?.jpegData(compressionQuality: 0.8) else {
            self.updateError(title: "Error Saving Recipe", body: "There was an error uploading your recipe. Please make sure you have a good internet connection", buttonText: nil)
            return
        }
        
        let ref = Storage.storage().reference(withPath: UUID().uuidString + self.title.capitalized)
        
        ref.putData(imageData) { metaData, error in
            if let error = error {
                self.updateError(title: "Error Saving Recipe", body: error.localizedDescription, buttonText: nil)
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    self.updateError(title: "Error Saving Recipe", body: error.localizedDescription, buttonText: nil)
                    return
                }
                
                photoUrl = url!.absoluteString
                self.addRecipeToFirebase(photoUrl)
            }
        }
    }
    
    func addRecipeToFirebase(_ url: String) {
        let recipeRef = Firestore.firestore().collection("Recipes").document()
        let userRef = Firestore.firestore().collection("users").document(dataAsRecipe["createdBy"] as! String)
        var data = self.dataAsRecipe
        data["photoUrl"] = url
        
        userRef.getDocument { doc, error in
            if let error = error {
                self.updateError(title: "Error Saving Recipe", body: error.localizedDescription, buttonText: nil)
                return
            }
            
            if let doc = doc, doc.exists {
                let userData = doc.data()
                if let userData = userData {
                    data["createdByName"] = userData["name"]
                    
                    recipeRef.setData(data, merge: true) {error in
                        if let error = error {
                            self.updateError(title: "Error Saving Recipe", body: error.localizedDescription, buttonText: nil)
                            return
                        }
                    }
                    
                    userRef.setData(["createdRecipes": FieldValue.arrayUnion([recipeRef.documentID])], merge: true) { error in
                        if let error = error {
                            self.updateError(title: "Error Saving Recipe", body: error.localizedDescription, buttonText: nil)
                        }
                        
                        withAnimation {
                            self.loading = false
                        }
                        
                        Task {
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            self.recipeDidAddToDB = true
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Ingredient Funcs
    func addIngredient() {
        withAnimation {
            ingredients.append(CreatingIngredient(id: UUID()))
        }
    }
    
    func removeLastIngredient() {
        if ingredients.count > 1 {
            withAnimation {
                ingredients.removeLast()
            }
        }
    }
    
    //MARK: Directions Funcs
    func addDirection() {
        withAnimation {
            directions.append((id: UUID(), value: ""))
        }
    }
    
    func removeLastDirection() {
        if directions.count > 1 {
            withAnimation {
                directions.removeLast()
            }
        }
    }
    
    //MARK: Category Funcs
    func addCategory(_ tag: String) {
        withAnimation {
            tags.append(tag)
        }
    }
    
    func removeCategory(_ tag: String) {
        if !tags.isEmpty {
            withAnimation {
                tags.removeAll {
                    $0 == tag
                }
            }
        }
    }
    
    func updateError(title: String, body: String, buttonText: String?) {
        withAnimation {
            self.showLoading = false
        }
        
        self.errorHeading = title
        self.errorBody = body
        self.errorBtn = buttonText ?? "Got it!"
        
        self.showAlert = true
    }
}

struct CreatingIngredient: Identifiable, Equatable {
    var id: UUID
    
    var title: String = ""
    var amount: String = ""
    var unit: String = ""
    
    var showUnits: Bool = false
}
