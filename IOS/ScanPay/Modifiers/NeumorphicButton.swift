//
//  NeumorphicButton.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct NeumorphicButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.darkShadow , radius: 8, x: 6, y: 6)
            .shadow(color: Color.lightShadow, radius: 8, x: -6, y: -6)
            
    }
}


@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func neumorphicButton() -> some View {
        return self.modifier(NeumorphicButton())
    }
    
}
