//
//  AccountCreationView.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct AccountCreationView: View {
    
    @Binding var showLogin: Bool
    @State private var name = ""
    @State private var phone = ""
    @State private var confirmedPassword = ""
    @State private var formOffset: CGFloat = 0
    
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject var manage : HttpAuth
    

    fileprivate func goToLoginButton() -> some View {
        return Button(action: {
            withAnimation(.spring() ) {
                self.showLogin.toggle()
            }
        }) {
            HStack {
                Text("Login")
                    .accentColor(Color.darkerAccent)
                Image(systemName: "arrow.right.square.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                    .foregroundColor(Color.darkerAccent)
                    
            }
        }
    }
    
    
    fileprivate func createContent() -> some View{
        ZStack{
        VStack {
                Image("scanPay-dynamic").resizable().aspectRatio(contentMode: .fit) .frame(height: 30)
                    .padding(.bottom)
        
            VStack(spacing: 10) {
                if(self.manage.emailNew){
                        CodeView().environmentObject(self.manage).onAppear(perform: self.saveVarible )
                    }
                    else {
                    Text("Create Account").font(.title).bold()
                    VStack(spacing: 6) {
                        SharedTextfield(value: self.$authManager.email,header: "Email", placeholder: "Your primary email",errorMessage: authManager.emailValidation.message)
                        SharedTextfield(value: self.$authManager.name,header: "Name and Surname", placeholder: "Your name and surname",errorMessage: authManager.nameValidation.message)
                        SharedTextfield(value: self.$authManager.phone,header: "Phone", placeholder: "Your phone",errorMessage: authManager.phoneValidation.message)
                        PasswordField(value: self.$authManager.password,header: "Password",  placeholder: "Make sure it's string",errorMessage: authManager.passwordValidation.message, isSecure: true)
                        PasswordField(value: self.$authManager.confirmedPassword,header: "Confirm Password",  placeholder: "Must match the password", errorMessage: authManager.confirmedPasswordValidation.message, isSecure: true)
                        Text(self.authManager.similarityValidation.message).foregroundColor(Color.red)
                        
                    }
                    LCButton(text: "Sign up", backgroundColor: self.authManager.canSignup && self.authManager.canSignupNamePhone ? Color.accent : Color.gray ) {self.manage.checkeEmail(email: self.authManager.email)}.disabled(!self.authManager.canSignup || !self.authManager.canSignupNamePhone)
                    
                }
                }.modifier(FormModifier()).offset(y: self.formOffset)
            
            goToLoginButton()
        }
            
        }.animation(.default)
        }
    
    
    private func saveVarible() {
             self.manage.email = self.authManager.email
        self.manage.password = self.authManager.password
        self.manage.phone = self.authManager.phone
        self.manage.name = self.authManager.name
    }
    
   
    var body: some View {
        
        SubscriptionView(content: createContent(), publisher: NotificationCenter.keyboardPublisher) { frame in
            withAnimation {
                self.formOffset = frame.height > 0 ? -200 : 0
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        AccountCreationView(showLogin: .constant(false)).environmentObject(HttpAuth()).environmentObject(AuthenticationManager())
    }
}
