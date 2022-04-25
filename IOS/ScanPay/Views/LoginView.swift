//
//  LoginView.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI
import Combine

struct LoginView: View {
    
    @Binding var showCreateAccount: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var formOffset: CGFloat = 0
    @EnvironmentObject var manage : HttpAuth
    @EnvironmentObject var authManager: AuthenticationManager

    fileprivate func createAccountButton() -> some View {
        return Button(action: {
            withAnimation(.spring()) {
                self.showCreateAccount.toggle()
            }
        }) {
            HStack {
                Image(systemName: "arrow.left.square.fill")
                .resizable()
                    .aspectRatio(contentMode: .fit)
                .frame(height: 20)
                    .foregroundColor(Color.darkerAccent)
                Text("Create account")
                    .accentColor(Color.darkerAccent)
            }
        }
    }
    
    
    fileprivate func createContent() -> some View {
        VStack {
            Image("scanPay-dynamic").resizable().aspectRatio(contentMode: .fit) .frame(height: 30)
            .padding(.bottom)
           
            VStack(spacing: 30) {
                Text("Login").font(.title).bold()
                VStack(spacing: 30) {
                    SharedTextfield(value: self.$authManager.email, header: "Email" , placeholder: "Your email",errorMessage: self.authManager.emailValidation.message)
                    PasswordField(value: self.$authManager.password, header: "Master Password", placeholder: "Make sure the password is strong", errorMessage: authManager.passwordValidation.message , isSecure: true)
                    
                    LCButton(text: "Login", backgroundColor: self.authManager.canLogin ? Color.accent : Color.gray ) {print(self.$authManager.email)
                        print(self.$authManager.password)
                        self.manage.checkDetails(username: self.authManager.email, password: self.authManager.password)
                        if self.manage.authenticated {
                            print("new")
                            
                        }
                        
                    }.disabled(!self.authManager.canLogin)
                    
                    
               
                }
                }.modifier(FormModifier()).offset(y: self.formOffset)
            createAccountButton()
        }
    }
    
    var body: some View {
        SubscriptionView(content: createContent(), publisher: NotificationCenter.keyboardPublisher) { frame in
            withAnimation {
                self.formOffset = frame.height > 0 ? -200 : 0
            }
        }
    }
}





struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showCreateAccount: .constant(false)).environmentObject(HttpAuth()).environmentObject(AuthenticationManager())
    }
}
