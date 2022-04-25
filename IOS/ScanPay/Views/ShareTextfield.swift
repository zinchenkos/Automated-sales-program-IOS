//
//  ShareTextfield.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct SharedTextfield: View {
    @Binding var value: String
     var header = "Username"
     var placeholder = "Your username or email"
     var trailingIconName = ""
     var errorMessage = ""
     var showUnderline = true
     var onEditingChanged: ((Bool)->()) = {_ in }
     var onCommit: (()->()) = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(header.uppercased()).font(.footnote).foregroundColor(Color.gray)
            HStack {
                TextField(placeholder, text: self.$value, onEditingChanged: { flag in
                    self.onEditingChanged(flag)
                }, onCommit: {
                    self.onCommit()
                }).padding(.vertical, 15)
                
                if !self.trailingIconName.isEmpty{
                    Image(systemName: self.trailingIconName ).foregroundColor(Color.gray)
                }
            }
            .frame(height: 45)
            if showUnderline{
                Rectangle().frame(height: 1).foregroundColor(Color.gray)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .lineLimit(nil)
                    .font(.footnote)
                    .foregroundColor(Color.red)
                    .transition(AnyTransition.opacity.animation(.easeIn))
            }
        }.background(Color.background)
    }
}

struct SharedTextfield_Previews: PreviewProvider {
    static var previews: some View {
        SharedTextfield(value: .constant(""))
    }
}
