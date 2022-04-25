//
//  ContentView.swift
//  ScanPay
//
//  Created by Pasha Boyko on 09.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject var manage : HttpAuth
    
    var body: some View {
        
   VStack {
    
    
    if UserDefaults.standard.bool(forKey: "authenticated") {
        //ScanView().transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))).environmentObject(manage)
        Home().environmentObject(self.manage).environmentObject(self.authManager)
    }
    else{
        AuthenticationView().environmentObject(self.manage).environmentObject(self.authManager)
    }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
   .background(Color.background)
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AuthenticationManager()).environmentObject(HttpAuth())
    }
}

