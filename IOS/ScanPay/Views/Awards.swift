//
//  Awards.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct Awards: View {
    
    @State var progressValueMax: Float = 10
    @State var progressValueNow: Float = 5
        var title = "Cкоро тут будут награды  "
           let longString = """
        За каждую награду ты будешь получать "Поинты", которые потом сможешь поменять на покупки в нашем магазине😊.
    """
    
    @State var textAward = "покупок молока"
        
          @State var image = "milk"

           var body: some View {
              VStack(spacing: 20.0) {
                VStack(spacing: 20.0) {
                 Text(title)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .lineLimit(nil).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 150 , alignment: .leading)
                    
                    ProgressBar(progressValueMax: self.$progressValueMax,progressValueNow: self.$progressValueNow, image: self.$image, textAward: self.$textAward)
                        .padding(.bottom, 80.0).modifier(FormModifier())
                                       

                 

                    Text(longString)
                        .lineLimit(nil)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                
                 Spacer()
              
                }
              .padding(30.0).background(Color.background.edgesIgnoringSafeArea(.all))
           }
    

    
    
    
        }



    struct Awards_Previews: PreviewProvider {
        static var previews: some View {
            Awards()
        }
    }



struct ProgressBar: View {
    @Binding var progressValueMax: Float
    @Binding var progressValueNow: Float
    @State var progressValue: Float = 0.0
    @Binding var image : String
    @Binding var textAward : String
    
    
    var body: some View {
        
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.accent)
            
            Circle()
                .trim(from: 0.0, to:CGFloat(self.progressValue))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.accent)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            
            Text(String(format: " Выполнено %.0f %% ", min(self.progressValue, 1.0)*100.0))
                .font(.title).bold().frame(minWidth: 300,maxWidth: .infinity).offset(y: 110)
            Text(String(format: "%0.f  c %.0f  %@", self.progressValueNow, self.progressValueMax, self.textAward))
            .bold().frame(minWidth: 300,maxWidth: .infinity).offset(y: 140)
            
            Image(image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 100)
            }.padding().onAppear(perform: startLoading).frame(width: 250.0, height: 180.0)
           
           
            
        
    }
    
    func startLoading() {
             _ = Timer.scheduledTimer(withTimeInterval: 0.009, repeats: true) { timer in
                 withAnimation() {
                     self.progressValue += 0.001
                    if self.progressValue >= (self.progressValueNow/self.progressValueMax) {
                         timer.invalidate()
                     }
                 }
             }
        
    }
       
    
}
