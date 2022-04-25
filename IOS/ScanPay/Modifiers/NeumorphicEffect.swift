//
//  NeumorphicEffect.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct NeumorphicEffect: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.darkShadow , radius: 10, x: 9, y: 9)
            .shadow(color: Color.lightShadow, radius: 10, x: -9, y: -9)
            
    }
}


@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func neumorphic() -> some View {
        return self.modifier(NeumorphicEffect())
    }
    
}
