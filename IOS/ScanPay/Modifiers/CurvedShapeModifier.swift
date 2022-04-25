//
//  CurvedShapeModifier.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct CurvedShapeModifier: ViewModifier {
    var shouldClip = false
    func body(content: Content) -> some View {
        
        if shouldClip {
            return AnyView(content.clipShape(CurvedShape()))
        } else {
            return AnyView(content)
        }
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func clip(shouldCurve: Bool) -> some View {
        self.modifier(CurvedShapeModifier(shouldClip: shouldCurve))
    }
}
