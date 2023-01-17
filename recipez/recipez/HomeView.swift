//
//  ContentView.swift
//  recipez
//
//  Created by Marcus Estrada on 12/27/22.
//

import SwiftUI

struct HomeView: View {
    @StateObject var recipeSearchViewModel = RecipeSearchViewModel()
    @State var search = ""
    
    @State var selectedMeal: Meal?
    @State var showDetails = false
    @Namespace var homeNamespace
    
    var body: some View {
            ZStack {
                    ScrollView(.vertical) {
                        VStack {
                            Text("Search")
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
                                        .strokeBorder(.green, antialiased: true)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.gray.opacity(0.2))
                                        }
                                    
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .font(.title3)
                                            .fontWeight(.light)
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
                                        
                                        
                                    }
                                    .padding()
                                }
                                .frame(maxHeight: 40)
                                Spacer(minLength: 30)
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
                
            
            //Hero View...
            showDetailsView()
                .ignoresSafeArea()
        }
            .background(Color("MainBackgroundColor"))
    }
    
    @ViewBuilder
    func showDetailsView () -> some View {
        if showDetails {
            ScrollView {
                VStack {
                    ZStack (alignment: .topLeading) {
                        AsyncImage(url: URL(string: selectedMeal?.strMealThumb ?? "")) { image in
                            image.resizable()
                                .matchedGeometryEffect(id: selectedMeal?.idMeal, in: homeNamespace)
                                .frame(height: 350)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        HStack {
                            Button {
                                withAnimation(.easeInOut(duration: 0.5)) {
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
                        Text(selectedMeal?.strMeal.capitalized ?? "")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 20) {
                            //ingredients
                            VStack(spacing: 15) {
                                ForEach(recipeSearchViewModel.getIngredients(for: selectedMeal!), id: \.self) {ingredient in
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
                                ForEach(recipeSearchViewModel.getMeasures(for: selectedMeal!), id: \.self) {measure in
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
                        
                        Text(selectedMeal?.strInstructions ?? "")
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
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 15) {
                ForEach(recipeSearchViewModel.meals.meals!, id: \.idMeal) { meal in
                    MealView(meal: meal, namespace: _homeNamespace)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showDetails.toggle()
                                selectedMeal = meal
                                //need to make api call to get single meal by id for full deets. api is poorly designed. This is whiy after searching, some meals will load with no other data than picture and title
                            }
                        }
                        .padding(.horizontal, 4)
                }
            }
        }
    }
}

struct MealView: View {
    let meal: Meal
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: meal.strMealThumb!)) { image in
                image.resizable()
                    .matchedGeometryEffect(id: meal.idMeal, in: namespace)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
