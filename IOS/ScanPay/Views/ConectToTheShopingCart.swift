//
//  ConectToTheShopingCart.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct ConectToTheShopingCart: View {
    var title = "Скоро ты первый раз подключишься к тележке"
    let longString = """
    Мы приготовили для тебя новую тележку, с которой ты почуствуешь, что магазины тоже не отстают от новых технологий 😊.

    Ты сможешь подключиться к ней и привязать свой аккаунт к ней на время покупки.

        
"""
    
    var image = "ShopingCart"
    
    var body: some View {
        VStack(spacing: 20.0) {
            VStack(spacing: 20.0) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .lineLimit(nil).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 150 , alignment: .leading)
                
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                
                Text(longString)
                    .lineLimit(nil)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            
        }
        .padding(30.0).background(Color.background.edgesIgnoringSafeArea(.all))
    }
}

struct ConectToTheShopingCart_Previews: PreviewProvider {
    static var previews: some View {
        ConectToTheShopingCart()
    }
}
