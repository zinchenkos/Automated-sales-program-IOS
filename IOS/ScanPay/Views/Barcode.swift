//
//  Barcode.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct Barcode: View {
   
    @State var name = "hj"
    @State var price = 50.00
    @State private var formOffset: CGFloat = 0

     
           var header = "Item"
           var placeholder = "Item"
           
          
    var body: some View {

        
        return VStack(alignment: .leading, spacing: 0) {

            HStack {
                Spacer()
                ZStack{
                    
                   Text(String(format:" Name : %@", name))
                
                }
                Spacer()
                
                ZStack{
                    Text(String(format:" Price : %.2f ₴", price))
                
                }
                
                Spacer()
                
                
                
            }.frame(height: 40.0)
            
        }.modifier(FormModifierItem())
    }
}

struct Barcode_Previews: PreviewProvider {
    static var previews: some View {
        Barcode()
    }
}

