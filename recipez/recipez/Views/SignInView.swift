//
//  SignInView.swift
//  recipez
//
//  Created by Marcus Estrada on 2/17/23.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @StateObject var onboardingVM = OnboardingViewModel()
    
    let passwordRequirement = "    Must be at least 8 characters"
    
    var formRectangle: some View {
        RoundedRectangle(cornerRadius: 15)
            .frame(minHeight: 30, maxHeight: 50)
            .foregroundColor(.black.opacity(0.55))
    }
    
    var passwordReqText: some View {
        HStack(alignment: .top) {
            Text(passwordRequirement)
                .foregroundColor(.white)
                .font(.caption)
            Spacer()
        }
        .frame(maxHeight: onboardingVM.password.count < 8 ? 12 : 0)
        .animation(.spring(), value: onboardingVM.password.count)
        .clipped()
    }
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.gray.opacity(0.0))
            
            VStack (spacing: 10) {
                Spacer()
                
                Text("RecipEz")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                
                ExpandableView (currentOnBoarding: $onboardingVM.currentOnboarding, targetOnboarding: OnBoardingType.signin) {
                    HStack {
                        Text("Sign In")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                        Spacer()
                    }
                } content: {
                    VStack (spacing: 8) {
                        ZStack {
                            formRectangle
                            
                            TextField("", text: $onboardingVM.email)
                                .placeholder(when: onboardingVM.email.isEmpty) {
                                    Text("Email")
                                        .foregroundColor(Color("AccentColor"))
                                }
                                .textInputAutocapitalization(.never)
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        
                        ZStack {
                            formRectangle
                            
                            SecureField("", text: $onboardingVM.password)
                                .placeholder(when: onboardingVM.password.isEmpty) {
                                    Text("Password")
                                        .foregroundColor(Color("AccentColor"))
                                }
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        passwordReqText
                        
                        Button {
                            onboardingVM.signInUser()
                        } label: {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(Color("AccentColor"))
                                .frame(minHeight: 30, maxHeight: 50)
                                .overlay {
                                    Text("Sign In")
                                        .foregroundColor(!onboardingVM.formIsValid ? .gray : .white)
                                        .fontWeight(.bold)
                                }
                        }
                        .disabled(!onboardingVM.formIsValid)
                        
                        Spacer()
                            .frame(maxHeight: 10)
                        
                    }
                    .onChange(of: onboardingVM.email) { newValue in
                        onboardingVM.validateForm()
                    }
                    .onChange(of: onboardingVM.password) { newValue in
                        onboardingVM.validateForm()
                    }
                }
                
                ExpandableView (currentOnBoarding: $onboardingVM.currentOnboarding, targetOnboarding: OnBoardingType.signup) {
                    HStack {
                        Text("Sign Up")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                        Spacer()
                    }
                } content: {
                    VStack (spacing: 10) {
                        ZStack {
                            formRectangle
                            
                            TextField("", text: $onboardingVM.email)
                                .placeholder(when: onboardingVM.email.isEmpty) {
                                    Text("Email")
                                        .foregroundColor(Color("AccentColor"))
                                }
                                .textInputAutocapitalization(.never)
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        ZStack {
                            formRectangle
                            
                            SecureField("", text: $onboardingVM.password)
                                .placeholder(when: onboardingVM.password.isEmpty) {
                                    Text("Password")
                                        .foregroundColor(Color("AccentColor"))
                                }
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        passwordReqText
                        
                        Button {
                            //needs data verification for text fields
                            onboardingVM.signUpUser()
                        } label: {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(Color("AccentColor"))
                                .frame(minHeight: 30, maxHeight: 50)
                                .overlay {
                                    Text("Sign Up")
                                        .foregroundColor(!onboardingVM.formIsValid ? .gray : .white)
                                        .fontWeight(.bold)
                                }
                        }
                        .disabled(!onboardingVM.formIsValid)
                        
                        Spacer()
                            .frame(maxHeight: 10)
                    }
                    .onChange(of: onboardingVM.email) { newValue in
                        onboardingVM.validateForm()
                    }
                    .onChange(of: onboardingVM.password) { newValue in
                        onboardingVM.validateForm()
                    }
                }
                
                ExpandableView (currentOnBoarding: $onboardingVM.currentOnboarding, targetOnboarding: OnBoardingType.forgot) {
                    HStack {
                        Text("Forgot Password?")
                            .font(.system(size: 17))
                        //.fontWeight(.bold)
                        Spacer()
                    }
                } content: {
                    VStack (spacing: 20) {
                        ZStack {
                            formRectangle
                            
                            TextField("", text: $onboardingVM.email)
                                .placeholder(when: onboardingVM.email.isEmpty) {
                                    Text("Email")
                                        .foregroundColor(Color("AccentColor"))
                                }
                                .textInputAutocapitalization(.never)
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        Button {
                            onboardingVM.forgotPassword()
                        } label: {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(Color("AccentColor"))
                                .frame(minHeight: 30, maxHeight: 50)
                                .overlay {
                                    Text("Submit")
                                        .foregroundColor(!onboardingVM.formIsValid ? .gray : .white)
                                        .fontWeight(.bold)
                                }
                        }
                        .disabled(!onboardingVM.formIsValid)
                        
                        Spacer()
                            .frame(maxHeight: 10)
                    }
                    .onChange(of: onboardingVM.email) { newValue in
                        onboardingVM.validateForm()
                    }
                }
                
                
                Text("or sign in with")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                
                HStack {
                    
                    Spacer()
                    
                    Button {
                        onboardingVM.signInWithGoogle()
                    } label: {
                        Circle()
                            .foregroundColor(.white)
                            .frame(maxWidth: 50)
                            .overlay {
                                Image("google")
                                    .resizable()
                                    .padding(13)
                            }
                    }
                    
                    Spacer()
                    
                    Button {
                        onboardingVM.signInWithApple()
                        print(Auth.auth().currentUser?.email ?? "No user")
                    } label: {
                        Circle()
                            .foregroundColor(.white)
                            .frame(maxWidth: 50)
                            .overlay {
                                Image("apple")
                                    .resizable()
                                    .padding(13)
                            }
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding()
            .alert(onboardingVM.alertTitle, isPresented: $onboardingVM.showAlert, actions: {
                Button("Retry") {
                    onboardingVM.resetAlert()
                }
            }, message: {
                Text(onboardingVM.alertDetails)
            })
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background {
            Image("Splash")
                .resizable(resizingMode: .stretch)
                .ignoresSafeArea()
                .aspectRatio(contentMode: .fill)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: onboardingVM.currentOnboarding) { newValue in
            onboardingVM.validateForm()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    
    static var previews: some View {
        SignInView()
    }
}


struct ExpandableView<Header: View, Content: View>: View {
    
    @State var isExpanded: Bool = true
    @State var appear: Bool = false
    
    @Binding var currentOnBoarding: OnBoardingType
    var targetOnboarding: OnBoardingType
    var label: () -> Header
    var content: () -> Content
    
    var body: some View {
        VStack (spacing:20) {
            Button {
                withAnimation {
                    currentOnBoarding = targetOnboarding
                }
            } label: {
                label()
                    .foregroundColor(currentOnBoarding == targetOnboarding ? .white : Color("AccentColor"))
            }
            
            if currentOnBoarding == targetOnboarding {
                VStack {
                    content()
                        .opacity(appear ? 1.0 : 0.0)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: currentOnBoarding == targetOnboarding ? .none : 0)
                .clipped()
                .onAppear {
                    withAnimation {
                        appear = true
                    }
                }
                .onDisappear {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        appear = false
                    }
                }
            }
        }
    }
}

//custom placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
