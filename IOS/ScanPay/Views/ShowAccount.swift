//
//  ShowAccount.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct ShowAccount: View{
    
    @EnvironmentObject var manage : HttpAuth
    @State private var formOffset: CGFloat = 0
    
    
    var body: some View {
        ZStack() {
            
            Color.background
            
            
            VStack() {
                
                
                Text("Account").font(.title).bold()
                VStack(spacing: 30) {
                    AccauntTextfield(header: "Name", placeholder: self.manage.user.name)
                    AccauntTextfield(header: "Email", placeholder: self.manage.user.email)
                    AccauntTextfield(header: "Phone", placeholder: self.manage.user.phone)
                    AccauntTextfield(header: "Points", placeholder: String(manage.user.points))
                    
                }
                
                
            }.modifier(FormModifier()).offset(y: self.formOffset)
        }.background(Color.background.edgesIgnoringSafeArea(.all))
        
    }
    
    
}



