//
//  AuthenticationView.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct AuthenticationView: View {
    
    @State private var showCreateAccount = false
    @EnvironmentObject var authManager: AuthenticationManager
     @EnvironmentObject var manage : HttpAuth
    
    
    
    var body: some View {
        VStack {
            if showCreateAccount {
                AccountCreationView(showLogin: self.$showCreateAccount)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))).environmentObject(self.manage).environmentObject(self.authManager)
            } else {
                LoginView(showCreateAccount: self.$showCreateAccount )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))).environmentObject(self.manage).environmentObject(self.authManager)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
         .edgesIgnoringSafeArea(.all)
        
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView().environmentObject(AuthenticationManager())
    }
}
