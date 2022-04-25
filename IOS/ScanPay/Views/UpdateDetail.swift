//
//  UpdateDetail.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct UpdateDetail: View {

   var title = "Скоро будет новые награды"
   var text = "Loading..."
   var image = "Illustration1"

   var body: some View {
      VStack(spacing: 20.0) {
        VStack(spacing: 20.0) {
         Text(title)
            .font(.largeTitle)
            .fontWeight(.heavy)
            .lineLimit(nil).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100 , alignment: .leading)

         Image(image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 200)

         Text(text)
            .lineLimit(nil)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }.modifier(FormModifier())
         Spacer()
      
        }
      .padding(30.0).background(Color.background.edgesIgnoringSafeArea(.all))
   }
}

#if DEBUG
struct UpdateDetail_Previews: PreviewProvider {
   static var previews: some View {
      UpdateDetail()
   }
}
#endif
