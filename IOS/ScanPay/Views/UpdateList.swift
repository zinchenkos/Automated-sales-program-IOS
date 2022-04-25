//
//  UpdateList.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct UpdateList: View {

  @EnvironmentObject var manage : HttpAuth
  

   var body: some View {
      NavigationView {
        ZStack(alignment: .top){
        Color.background
         List {
            ForEach(manage.news) { item in
               NavigationLink(destination: UpdateDetail(title: item.header, text: item.text, image: "news")) {
                  HStack(spacing: 12.0) {
                     Image("news")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .background(Color("background"))
                        .cornerRadius(20)

                     VStack(alignment: .leading) {
                        Text(item.header)
                           .font(.headline)

                        Text(item.text)
                           .lineLimit(2)
                           .lineSpacing(4)
                           .font(.subheadline)
                           .frame(height: 50.0)

                        Text(item.date)
                           .font(.caption)
                           .fontWeight(.bold)
                           .foregroundColor(.gray)
                     }
                  Spacer()
                  }.modifier(FormModifier())
               }
               
            }
         }
         .navigationBarTitle(Text("News"))
        }.background(Color.background.edgesIgnoringSafeArea(.all))
        }.background(Color.background.edgesIgnoringSafeArea(.all))
   }
}

#if DEBUG
struct UpdateList_Previews: PreviewProvider {
   static var previews: some View {
    UpdateList().environmentObject(HttpAuth())
   }
}
#endif

struct Update: Identifiable {
   var id = UUID()
   var image: String
   var title: String
   var text: String
   var date: String
}

