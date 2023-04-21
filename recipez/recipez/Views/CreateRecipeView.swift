//
//  CreateRecipeView.swift
//  recipez
//
//  Created by Marcus Estrada on 4/2/23.
//

import SwiftUI
import PhotosUI

struct CreateRecipeView: View {
    @Binding var showCreateScreen: Bool
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var createRecipeVM = CreateRecipeViewModel()
    
    @State var currentCategoryText = ""
    @State var showPhotoPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                //MARK: Top Section
                Section {
                    VStack {
                        RoundedRectangle(cornerRadius: 10.0)
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                            .overlay {
                                if createRecipeVM.image == nil {
                                    Image(systemName: "camera")
                                        .font(.title)
                                } else {
                                    Image(uiImage: createRecipeVM.image!)
                                        .resizable()
                                        .cornerRadius(10.0)
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                        
                        Button {
                            showPhotoPicker = true
                        } label: {
                            Text(createRecipeVM.image == nil ? "Add Photo" : "Change Photo")
                        }
                    }
                    .sheet(isPresented: $showPhotoPicker, content: {
                        //PhotoPickerView
                        PhotoPickerView(image: $createRecipeVM.image) { didSelectItem in
                            showPhotoPicker = false
                            if didSelectItem {
                                //
                            }
                        }
                    })
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    TextField("Recipe Title", text: $createRecipeVM.title)
                    
                    Picker("Food or Bev", selection: $createRecipeVM.selectedRecipeType) {
                        ForEach(createRecipeVM.recipeTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 10)
                }
                
                //MARK: Ingredients View
                Section("Ingredients") {
                    ForEach (createRecipeVM.ingredients) { ingredient in
                        IngredientView(ingredient: $createRecipeVM.ingredients.first(where: {$0.id == ingredient.id})!)
                    }
                    
                    HStack {
                        Button {
                            createRecipeVM.removeLastIngredient()
                        } label: {
                            Image(systemName: "minus")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Divider()
                        
                        Button {
                            createRecipeVM.addIngredient()
                        } label: {
                            Image(systemName: "plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
                // MARK: Directions View
                Section("Directions") {
                    ForEach(createRecipeVM.directions, id: \.id) { direction in
                        let stepNumber = createRecipeVM.directions.firstIndex {
                            $0 == direction
                        }
                        DirectionView(content: $createRecipeVM.directions[stepNumber!].value, stepNumber: stepNumber!)
                    }
                    
                    HStack {
                        Button {
                            createRecipeVM.removeLastDirection()
                        } label: {
                            Image(systemName: "minus")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Divider()
                        
                        Button {
                            createRecipeVM.addDirection()
                        } label: {
                            Image(systemName: "plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
                //MARK: Categories View
                Section("Categories") {
                    HStack {
                        TextField("Lunch, Keto, Continental ...", text: $currentCategoryText)
                        Divider()
                        Button {
                            createRecipeVM.addCategory(currentCategoryText)
                            currentCategoryText = ""
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(currentCategoryText.count < 3)
                        .padding(10)
                    }
                    .padding(.vertical, 2)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                        ForEach(createRecipeVM.tags, id: \.self) {
                            CategoryView(content: $0) {
                                createRecipeVM.removeCategory($0)
                            }
                        }
                    }
                    .padding(5)
                }
                
                //MARK: Optional Information
                Section("Optional Recipe Info") {
                    HStack {
                        Text("Servings")
                            .foregroundColor(Color("AccentColor"))
                        Spacer()
                        TextField("Amount", text: $createRecipeVM.servings)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 75)
                    }
                    .padding(.vertical, 10)
                    
                    HStack {
                        Text("Calories per servings")
                            .foregroundColor(Color("AccentColor"))
                        Spacer()
                        TextField("Amount", text: $createRecipeVM.calsPerServing)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 75)
                    }
                    .padding(.vertical, 10)
                    
                    VStack (alignment: .leading) {
                        Text("Recommendations or Notes")
                            .foregroundColor(Color("AccentColor"))
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(Color("MainBackgroundColor"))
                            if createRecipeVM.recommendations.isEmpty {
                                Text("Recommendations?")
                                    .foregroundColor(.gray.opacity(0.4))
                                    .padding(.horizontal, 10)
                            }
                            TextEditor(text: $createRecipeVM.recommendations)
                                .padding(.top, 12)
                                .padding(.horizontal, 8)
                        }
                    }
                    .frame(minHeight: 82)
                    .padding(.vertical, 10)
                }
                
            }
            .navigationBarTitle(Text("New Recipe"))
            .alert(isPresented: $createRecipeVM.showAlert) {
                Alert(title: Text(createRecipeVM.errorHeading), message: Text(createRecipeVM.errorBody), dismissButton: .default(Text(createRecipeVM.errorBtn)))
            }
            .toolbar {
                ToolbarItem (placement: .navigationBarLeading) {
                    Button(role: .cancel) {
                        showCreateScreen = false
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem {
                    Button {
                        guard createRecipeVM.validateRecipe() else {
                            return
                        }
                        Task {
                            await createRecipeVM.commitImageToDB()
                        }
                    } label: {
                        Text("Save")
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }

                }
            }
            .accentColor(Color("AccentColor"))
        }
        .background {
            Color("MainBackgroundColor")
        }
        .overlay {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .frame(minWidth: 100, idealWidth: 150, maxWidth: 200, minHeight: 100, idealHeight: 150, maxHeight: 200)
                    .foregroundColor(.gray.opacity(0.2))
                    .blur(radius: 2)
                
                getLoadingView(createRecipeVM.loading)
            }
            .opacity(createRecipeVM.showLoading ? 100 : 0)
        }
        .onChange(of: createRecipeVM.recipeDidAddToDB) {
            if $0 {
                showCreateScreen = false
            }
        }
    }
    
    struct IngredientView: View {
        @Binding var ingredient: CreatingIngredient
        
        var body: some View {
            HStack (spacing: 0) {
                TextField("Ingredient", text: $ingredient.title)
                    .font(.callout)
                TextField("Amount", text: $ingredient.amount)
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: 60)
                    .font(.callout)
                    .multilineTextAlignment(.trailing)
                Text(ingredient.unit == "" ? "Unit" : ingredient.unit)
                    .frame(width: 70)
                    .font(.callout)
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundColor(Color("AccentColor"))
                    .onTapGesture {
                        ingredient.showUnits = true
                    }
            }
            .padding(.vertical, 10)
            .listRowSeparator(.hidden)
            .sheet(isPresented: $ingredient.showUnits) {
                if #available(iOS 16.0, *) {
                    GetUnitsView(unit: $ingredient.unit, show: $ingredient.showUnits)
                        .presentationDetents([.fraction(0.67)])
                        .presentationDragIndicator(.visible)
                } else {
                    GetUnitsView(unit: $ingredient.unit, show: $ingredient.showUnits)
                }
            }
        }
    }
    
    struct DirectionView: View {
        @Binding var content: String
        @State var stepNumber: Int
        var body: some View {
            VStack (alignment: .leading) {
                Text("Step \(stepNumber + 1)")
                    .foregroundColor(Color("AccentColor"))
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color("MainBackgroundColor"))
                    if content.isEmpty {
                        Text("Let's cook ...")
                            .foregroundColor(.gray.opacity(0.4))
                            .padding(.horizontal, 10)
                    }
                    TextEditor(text: $content)
                        .padding(.top, 12)
                        .padding(.horizontal, 8)
                }
            }
            .frame(minHeight: 82)
            .listRowSeparator(.hidden)
            .padding(.vertical, 10)
        }
    }
    
    struct CategoryView: View {
        let content: String
        let function: (String) -> Void
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("MainBackgroundColor"))
                HStack (spacing: 5) {
                    Text(content)
                        .font(.callout)
                        .frame(minHeight: 35)
                        .fixedSize(horizontal: false, vertical: true)
                    Button {
                        function(content)
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("AccentColor"))
                            .font(.callout.bold())
                            .frame(height: 35)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
    }
    
    @ViewBuilder
    func getLoadingView(_ showLoading: Bool) -> some View {
        if showLoading {
            ProgressView("Creating Recipe")
                .scaleEffect(1.5)
                .font(.caption)
                .tint(Color("AccentColor"))
        } else {
            VStack {
                Image(systemName: "checkmark")
                    .font(.title)
                    .padding(.vertical, 10)
                .foregroundColor(.accentColor)
                Text("Recipe Created \n  Successfully!")
                    .font(.callout)
                    .bold()
                    .foregroundColor(.gray)
            }
        }
    }
}

struct GetUnitsView: View {
    @Binding var unit: String
    @Binding var show: Bool
    @State var searchText = ""
    
    @Environment(\.colorScheme) var colorScheme
    
    let units = ["lbs", "tsp", "tbsp", "gallons", "liters", "grams", "kg", "slice", "oz", "pinch", "clove", "handful", "none", "whole", "halves", "quarters", "eighths", "cups", "quart", "pint", "fl oz"]
    
    var searchResults: [String] {
        let alteredText = searchText.lowercased()
        if alteredText.isEmpty {
            return units.sorted()
        } else {
            return units.filter {
                $0.contains(alteredText)
            }.sorted()
        }
    }
    
    var body: some View {
        NavigationView {
            if #available(iOS 16.0, *) {
                List {
                    ForEach(searchResults, id: \.self) { unit in
                        Button {
                            self.unit = unit
                            show = false
                        } label: {
                            Text(unit)
                        }
                        
                    }
                }
                .scrollIndicators(.hidden)
                .padding()
                .background(content: {
                    if colorScheme == .light {
                        Color("MainBackgroundColor")
                            .ignoresSafeArea(.all)
                    }
                })
                .navigationBarTitle(Text("Select Unit"))
            } else {
                List {
                    ForEach(searchResults, id: \.self) { unit in
                        Button {
                            self.unit = unit
                            show = false
                        } label: {
                            Text(unit)
                        }
                        
                    }
                }
                .padding()
                .background(content: {
                    if colorScheme == .light {
                        Color("MainBackgroundColor")
                            .ignoresSafeArea(.all)
                    }
                })
                .navigationBarTitle(Text("Select Unit"))
            }
        }
        .searchable(text: $searchText)
    }
}



struct CreateRecipeView_Previews: PreviewProvider {
    
    @State static var value = true
    
    static var previews: some View {
        CreateRecipeView(showCreateScreen: $value)
    }
}
