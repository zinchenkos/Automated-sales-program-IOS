//
//  AccauntTextfield.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct AccauntTextfield: View {
    

    var header = "Username"
    var placeholder = "Your username or email"
    var showUnderline = true
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
        Text(header.uppercased()).font(.footnote).foregroundColor(Color.gray)
        HStack {
            Text(placeholder).foregroundColor(Color.gray).padding(.vertical, 15)
            }
            if showUnderline{
                Rectangle().frame(height: 1).foregroundColor(Color.gray)
            }
    }.background(Color.background)
}
}

struct AccauntTextfield_Previews: PreviewProvider {
    static var previews: some View {
        AccauntTextfield()
    }
}
