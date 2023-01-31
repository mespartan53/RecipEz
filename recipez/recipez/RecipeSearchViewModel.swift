//
//  RecipeSearchViewModel.swift
//  recipez
//
//  Created by Marcus Estrada on 1/10/23.
//

import Foundation

class RecipeSearchViewModel: ObservableObject {
    @Published private(set) var meals = Response(meals: [])
    @Published private(set) var selectedMeal = Response(meals: [])
    
    var allMeals: [Meal] {
        meals.meals ?? []
    }
    
    @MainActor func setSelectedMeal(for id: String) async {
        guard let url = URL(string: MealDBurls.baseURL + MealDBurls.fullMealById + id)
        else {
            print("Invalid URL for selected meal")
            return
        }
        let urlSession = URLSession.shared
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            self.selectedMeal = try JSONDecoder().decode(Response.self, from: data)
            
        } catch {
            //Handle error
            print("Error selecting a single meal")
        }
    }
    
    func getIngredients(for meal: Meal) -> [String] {
        var ingredients: [String] = []
        
        if let ingredient1 = meal.strIngredient1 {
            if ingredient1.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient1)
            }
        }
        
        if let ingredient2 = meal.strIngredient2 {
            if ingredient2.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient2)
            }
        }
        
        if let ingredient3 = meal.strIngredient3 {
            if ingredient3.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient3)
            }
        }
        
        if let ingredient4 = meal.strIngredient4 {
            if ingredient4.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient4)
            }
        }
        
        if let ingredient5 = meal.strIngredient5 {
            if ingredient5.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient5)
            }
        }
        
        if let ingredient6 = meal.strIngredient6 {
            if ingredient6.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient6)
            }
        }
        
        if let ingredient7 = meal.strIngredient7 {
            if ingredient7.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient7)
            }
        }
        
        if let ingredient8 = meal.strIngredient8 {
            if ingredient8.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient8)
            }
        }
        
        if let ingredient9 = meal.strIngredient9 {
            if ingredient9.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient9)
            }
        }
        
        if let ingredient10 = meal.strIngredient10 {
            if ingredient10.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient10)
            }
        }
        
        if let ingredient11 = meal.strIngredient11 {
            if ingredient11.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient11)
            }
        }
        
        if let ingredient12 = meal.strIngredient12 {
            if ingredient12.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient12)
            }
        }
        
        if let ingredient13 = meal.strIngredient13 {
            if ingredient13.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient13)
            }
        }
        
        if let ingredient14 = meal.strIngredient14 {
            if ingredient14.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient14)
            }
        }
        
        if let ingredient15 = meal.strIngredient15 {
            if ingredient15.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient15)
            }
        }
        
        if let ingredient16 = meal.strIngredient16 {
            if ingredient16.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient16)
            }
        }
        
        if let ingredient17 = meal.strIngredient17 {
            if ingredient17.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient17)
            }
        }
        
        if let ingredient18 = meal.strIngredient18 {
            if ingredient18.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient18)
            }
        }
        
        if let ingredient19 = meal.strIngredient19 {
            if ingredient19.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient19)
            }
        }
        
        if let ingredient20 = meal.strIngredient20 {
            if ingredient20.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                ingredients.append(ingredient20)
            }
        }
        
        return ingredients
    }
    
    func getMeasures(for meal: Meal) -> [String] {
        var measures: [String] = []
        
        if let measure1 = meal.strMeasure1 {
            if measure1.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure1)
            }
        }
        
        if let measure2 = meal.strMeasure2 {
            if measure2.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure2)
            }
        }
        
        if let measure3 = meal.strMeasure3 {
            if measure3.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure3)
            }
        }
        
        if let measure4 = meal.strMeasure4 {
            if measure4.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure4)
            }
        }
        
        if let measure5 = meal.strMeasure5 {
            if measure5.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure5)
            }
        }
        
        if let measure6 = meal.strMeasure6 {
            if measure6.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure6)
            }
        }
        
        if let measure7 = meal.strMeasure7 {
            if measure7.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure7)
            }
        }
        
        if let measure8 = meal.strMeasure8 {
            if measure8.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure8)
            }
        }
        
        if let measure9 = meal.strMeasure9 {
            if measure9.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure9)
            }
        }
        
        if let measure10 = meal.strMeasure10 {
            if measure10.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure10)
            }
        }
        
        if let measure11 = meal.strMeasure11 {
            if measure11.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure11)
            }
        }
        
        if let measure12 = meal.strMeasure12 {
            if measure12.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure12)
            }
        }
        
        if let measure13 = meal.strMeasure13 {
            if measure13.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure13)
            }
        }
        
        if let measure14 = meal.strMeasure14 {
            if measure14.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure14)
            }
        }
        
        if let measure15 = meal.strMeasure15 {
            if measure15.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure15)
            }
        }
        
        if let measure16 = meal.strMeasure16 {
            if measure16.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure16)
            }
        }
        
        if let measure17 = meal.strMeasure17 {
            if measure17.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure17)
            }
        }
        
        if let measure18 = meal.strMeasure18 {
            if measure18.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure18)
            }
        }
        
        if let measure19 = meal.strMeasure19 {
            if measure19.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure19)
            }
        }
        
        if let measure20 = meal.strMeasure20 {
            if measure20.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                measures.append(measure20)
            }
        }
        
        return measures
    }
    
    func loadByName(name: String) {
        let urlString = MealDBurls.baseURL + MealDBurls.searchByName + name
        guard let url = URL(string: urlString)
        else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(Response.self, from: data)
                    DispatchQueue.main.async {
                        if response.meals != nil {
                            self.meals = response
                        }
                    }
                } catch let jsonError as NSError {
                    print("JSON decode failed: \(jsonError)")
                }
                return
            }
        }
        task.resume()
    }
    
    func loadByIngredients(ingredients: String) {
        let urlString = MealDBurls.baseURL + MealDBurls.filterByIngredient + ingredients
        guard let url = URL(string: urlString)
        else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(Response.self, from: data)
                    DispatchQueue.main.async {
                        self.meals = response
                    }
                } catch let jsonError as NSError {
                    print("JSON decode failed: \(jsonError)")
                }
                return
            }
        }
        task.resume()
    }
    
    func loadRandomSelection() {
        let urlString = MealDBurls.baseURL + MealDBurls.randomSelection
        guard let url = URL(string: urlString)
        else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(Response.self, from: data)
                    DispatchQueue.main.async {
                        self.meals = response
                    }
                } catch let jsonError as NSError {
                    print("JSON decode failed: \(jsonError)")
                }
                return
            }
        }
        task.resume()
    }
}

struct MealDBurls {
    static let baseURL = "https://www.themealdb.com/api/json/v2/9973533/"
    static let searchByName = "search.php?s="
    static let singleRandom = "random.php"
    static let randomSelection = "randomselection.php"
    static let latest = "latest.php"
    static let filterByIngredient = "filter.php?i="
    static let fullMealById = "lookup.php?i="
}
