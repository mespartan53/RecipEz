//
//  MainView.swift
//  recipez
//
//  Created by Marcus Estrada on 2/9/23.
//

import SwiftUI
import Combine
import FirebaseAuth

struct MainView: View {
    @StateObject var mainVM: MainViewModel = MainViewModel()
    @State var appear = 100.0
    
    var body: some View {
        if !mainVM.isSignedIn {
            SignInView()
                .onAppear {
                    withAnimation {
                        appear = 100
                    }
                }
                .onDisappear {
                    withAnimation {
                        appear = 0
                    }
                }
                .opacity(appear)
        } else {
            TabView(selection: $mainVM.itemSelected) {
                Group {
                    HomeView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(0)
                    
                    Text("Browse")
                        .tabItem {
                            Label("Browse", systemImage: "fork.knife")
                        }
                        .tag(1)
                    
                    Text("Create")
                        .tabItem {
                            Label("Create", systemImage: "plus")
                        }
                        .tag(2)
                    
                    
                    Text("Shopping List")
                        .tabItem {
                            Label("Shopping List", systemImage: "cart")
                        }
                        .tag(3)
                    
                    Button {
                        mainVM.signOutUser()
                        mainVM.itemSelected = 1
                    } label: {
                        Text("Sign out")
                    }
                    .tabItem {
                        Label("Favorites", systemImage: "heart")
                    }
                    .tag(4)
                }
                .fullScreenCover(isPresented: $mainVM.showCreateScreen) {
                    CreateRecipeView(showCreateScreen: $mainVM.showCreateScreen)
                }
            }
            .accentColor(Color("AccentColor"))
        }
    }
}

class MainViewModel: ObservableObject {
    let objectWillChange = PassthroughSubject<MainViewModel,Never>()
    
    @Published var isSignedIn: Bool {
        didSet {
            objectWillChange.send(self)
        }
    }
    @Published var showCreateScreen: Bool {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    @Published var itemSelected: Int {
        didSet {
            if itemSelected == 2 {
                itemSelected = oldValue
                self.showCreateScreen = true
            }
            objectWillChange.send(self)
        }
    }
    
    init() {
        self.itemSelected = 1
        self.showCreateScreen = false
        
        if Auth.auth().currentUser != nil {
            self.isSignedIn = true
        } else {
            self.isSignedIn = false
        }
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                withAnimation(.spring()) {
                    self.isSignedIn = true
                }
                
            } else {
                withAnimation(.spring()) {
                    self.isSignedIn = false
                }
                
            }
        }
    }
    
    func signOutUser() {
        try! Auth.auth().signOut()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
