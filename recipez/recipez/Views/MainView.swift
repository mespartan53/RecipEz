//
//  MainView.swift
//  recipez
//
//  Created by Marcus Estrada on 2/9/23.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @StateObject var mainVM = MainViewModel()
    
    @State var tabNumber :Int = 1
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
                .animation(.spring(), value: appear)
        } else {
            TabView(selection: $tabNumber) {
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
                    } label: {
                        Text("Sign out")
                    }
                        .tabItem {
                            Label("Favorites", systemImage: "heart")
                        }
                        .tag(4)
                }
            }
            .accentColor(Color("AccentColor"))
        }
    }
}

class MainViewModel: ObservableObject {
    @Published var isSignedIn = false
    
    init() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.isSignedIn = true
            } else {
                self.isSignedIn = false
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
