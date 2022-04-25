//
//  FormModifier.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct FormModifier: ViewModifier {
        
     func body(content: Content) -> some View {
        content.padding()
                 .background(Color.background)
                             .cornerRadius(10)
                             .padding()
                            .neumorphic()
                             
               
       }
}

struct FormModifierItem: ViewModifier {
        
     func body(content: Content) -> some View {
        content.padding()
                 .background(Color.background)
                             .cornerRadius(10)
                        
                            .neumorphic()
                             
               
       }
}

struct FormModifierButton: ViewModifier {
        
     func body(content: Content) -> some View {
        content.padding(10)
                 .background(Color.background)
                             .cornerRadius(25)
                            .neumorphicButton()
                             
               
       }
}
