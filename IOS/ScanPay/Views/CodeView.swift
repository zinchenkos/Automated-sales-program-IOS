//
//  CodeView.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

struct CodeView: View {
  @EnvironmentObject var manage : HttpAuth
   @State var progressValue: Float = 1.0
    @State var progressSec: Float = 60
   @Environment(\.presentationMode) var mode: Binding<PresentationMode>
   
    
    
    
    var body: some View {
        
        ZStack {
            VStack{
            VStack(alignment: .leading) {
            
                Text("Please enter your verification code")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                Text("We have sent you a four-digit PIN to verificate your email number.")
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true).padding(.bottom, 20)
                    
                }
                VStack(alignment: .center){
                    ZStack {
                     Circle()
                         .stroke(lineWidth: 20.0)
                         .opacity(0.3)
                         .foregroundColor(Color.accent)
                     
                     Circle()
                         .trim(from: 0.0, to: CGFloat(progressValue))
                         .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                         .foregroundColor(Color.accent)
                         .rotationEffect(Angle(degrees: 270.0))
                         .animation(.linear)
                     
                     Text(String(format: " %.f  C ", self.progressSec))
                         .font(.title).bold().frame(minWidth: 0,maxWidth: .infinity)
                     
                    }.padding(.bottom, 42.0).onAppear(perform: startLoading).frame(width: 250.0, height: 180.0)
                    
                SecureField("PIN", text: self.$manage.enteredPin)
                    .keyboardType(.numberPad)
                    .padding().modifier(FormModifier())
                    
          
            }
                
        }.background(Color.background)
    
        
        
    }
        
    }
        
        
private func startLoading() {
               
               _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                           withAnimation() {
                               if self.progressSec <= 0  {
                                   timer.invalidate()
                                   self.manage.enteredPin = ""
                                   self.mode.wrappedValue.dismiss()
                               }
                            print( self.manage.authenticated)
                               
                               if self.manage.authenticated{
                                   print("mkdwmlkmdskmdskdskkkmkkk")
                                   timer.invalidate()
                                   self.manage.enteredPin = ""
                                   self.mode.wrappedValue.dismiss()
                                   
                               }
                           
                               
                               if self.progressSec > 0 {
                                   print(111111)
                                   self.progressValue -= (0.5/60)
                                   self.progressSec -= 0.5
                               }
                               }
                       }
                  
              }
           
}

struct CodeView_Previews: PreviewProvider {
    static var previews: some View {
        CodeView().environmentObject(HttpAuth())
        
    }
}



