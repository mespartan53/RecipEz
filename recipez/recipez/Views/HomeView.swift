//
//  ContentView.swift
//  recipez
//
//  Created by Marcus Estrada on 12/27/22.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject var recipeSearchViewModel = RecipeSearchViewModel()
    @State var search = ""
    
    @State var selectedMeal: Meal?
    @State var showDetails = false
    @Namespace var homeNamespace : Namespace.ID
    
    var body: some View {
            ZStack {
                if !showDetails {
                    ScrollView(.vertical) {
                            VStack {
                                Text("Ingredient Search")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Spacer(minLength: 40)
                                Group {
                                    Text("What's in your kitchen?")
                                        .font(.title2)
                                    Text("Enter some ingredients")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                    Spacer(minLength: 30)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color("AccentColor"), antialiased: true)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(.gray.opacity(0.2))
                                            }
                                        
                                        HStack {
                                            Image(systemName: "magnifyingglass")
                                                .font(.title3)
                                                .foregroundColor(Color("AccentColor"))
                                            TextField("chicken , salt, garlic ...", text: $search, onCommit: {
                                                //move to seperate function in view model once created
                                                let pattern = "\\s+"
                                                
                                                do {
                                                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                                                    let modifiedString = regex.stringByReplacingMatches(in: search, range: NSRange(location: 0, length: search.utf16.count), withTemplate: ",")
                                                    recipeSearchViewModel.loadByIngredients(ingredients: modifiedString)
                                                } catch {
                                                    print("Oops! Something went wrong")
                                                }
                                            })
                                            .disableAutocorrection(true)
                                            .submitLabel(.search)
                                            
                                            Button {
                                                recipeSearchViewModel.loadRandomSelection()
                                            } label: {
                                                Image(systemName: "questionmark.app.dashed")
                                                    .font(.title)
                                                    .foregroundColor(Color("AccentColor"))
                                            }

                                        }
                                        .padding()
                                    }
                                    .frame(maxHeight: 40)
                                    Spacer(minLength: 40)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                
                                recipeViews()
                            }
                        }
                        .padding()
                        .onAppear {
                            if recipeSearchViewModel.meals.meals == [] {
                                recipeSearchViewModel.loadRandomSelection()
                            }
                    }
                }
                
            
            //Hero View...
            showDetailsView()
                .ignoresSafeArea()
                .zIndex(2)
        }
            .background(Color("MainBackgroundColor"))
    }
    
    @ViewBuilder
    func showDetailsView () -> some View {
        if showDetails {
            ScrollView {
                VStack {
                    ZStack (alignment: .topLeading) {
                        AsyncImage(url: URL(string: recipeSearchViewModel.selectedMeal.meals?[0].strMealThumb ?? "")) { image in
                            image.resizable()
                                .matchedGeometryEffect(id: recipeSearchViewModel.selectedMeal.meals?[0].idMeal, in: homeNamespace)
                                .frame(height: 350)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        HStack {
                            Button {
                                withAnimation(.spring()) {
                                    showDetails.toggle()
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.body)
                            }
                            .padding()
                            .background(Circle().foregroundColor(.black.opacity(0.5)))
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button {
                                print(recipeSearchViewModel.getIngredients(for: selectedMeal!))
                                print(selectedMeal!)
                            } label: {
                                Image(systemName: "heart")
                                    .font(.title2)
                            }
                            .padding()
                            .background(Circle().foregroundColor(.black.opacity(0.5)))
                            .foregroundColor(.white)
                        }
                        .padding()
                        .offset(y: 40)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(recipeSearchViewModel.selectedMeal.meals?[0].strMeal.capitalized ?? "")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 20) {
                            //ingredients
                            VStack(spacing: 15) {
                                ForEach(recipeSearchViewModel.getIngredients(for: recipeSearchViewModel.selectedMeal.meals![0]), id: \.self) {ingredient in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundColor(Color("DetailsColor"))
                                            .frame(height: 50)
                                            .shadow(radius: 0.5, x: 1, y: 1)
                                        Text(ingredient)
                                    }
                                }
                            }
                            //units of measure
                            VStack(spacing: 15) {
                                ForEach(recipeSearchViewModel.getMeasures(for: recipeSearchViewModel.selectedMeal.meals![0]), id: \.self) {measure in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundColor(Color("DetailsColor"))
                                            .frame(height: 50)
                                            .shadow(radius: 0.5, x: 1, y: 1)
                                        Text(measure)
                                    }
                                }
                            }
                        }.frame(maxWidth: .infinity)
                            .padding(.vertical)
                        
                        Text(recipeSearchViewModel.selectedMeal.meals?[0].strInstructions ?? "")
                            .padding()
                        
                    }.padding(.horizontal)
                    
                    //add deets
                    Spacer(minLength: 30)
                }
            }
            .background(
                Color("MainBackgroundColor")
            )
        }
    }
    
    @ViewBuilder
    func recipeViews() -> some View {
        if recipeSearchViewModel.meals.meals == nil {
            Text("Nothing to see here :)")
        } else if recipeSearchViewModel.meals.meals == [] {
            Text("Nothing to see here :)")
        } else {
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 25) {
                ForEach(recipeSearchViewModel.meals.meals!, id: \.idMeal) { meal in
                    MealView(meal: meal)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                //Can remove this once the print function for the heart icon is updated
                                selectedMeal = meal
                                Task() {
                                    await recipeSearchViewModel.setSelectedMeal(for: meal.idMeal)
                                    withAnimation(.spring()) {
                                        showDetails.toggle()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                }
            }
        }
    }
    
    struct MealView: View {
        let meal: Meal
        @Namespace var homeNamespace: Namespace.ID
        
        var body: some View {
            ZStack {
                AsyncImage(url: URL(string: meal.strMealThumb!)) { image in
                    image.resizable()
                        .matchedGeometryEffect(id: meal.idMeal, in: homeNamespace)
                } placeholder: {
                    ProgressView()
                }
                .cornerRadius(15)
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 40, height: 50)
                            .foregroundColor(.gray.opacity(0.65))
                        Image(systemName: "heart")
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    Spacer()
                    Text(meal.strMeal)
                        .foregroundColor(.white)
                        .font(.body)
                        .fontWeight(.bold)
                        .shadow(color: .black, radius: 15)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .padding()
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
