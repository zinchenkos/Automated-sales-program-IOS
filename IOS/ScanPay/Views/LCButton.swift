//
//  LCButton.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct LCButton: View {
    var text = ""
    var backgroundColor = Color.black
    var action = {}
    
    var body: some View {
        Button(action: {
            HapticFeedback.generate()
            self.action()
        }) {
            HStack {
                Text(text)
                    .font(.system(size: 20, weight: Font.Weight.semibold))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(.vertical)
                    .accentColor(Color.white)
                    .background(backgroundColor.opacity(0.9))
                    .cornerRadius(20)
            }
        }
    }
}

struct LCButton_Previews: PreviewProvider {
    static var previews: some View {
        LCButton()
    }
}
