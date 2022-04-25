//
//  ScanView.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI



struct ScanView: View {
    @State private var isSendingPending = false
    @State private var paymentSent = false
    @State var barcodeValue = "Barcode"
    @State private var formOffset: CGFloat = -75
    @State var torceIsOn = false
    @State private var showMenu = false
    private let okView = OkView(width: 30, lineWidth: 7)
    private let loadingView = LoadingView(lineWidth: 7)
    
    init() {
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = UIColor.clear
        
        
        
    }
    
    
    
    
    
    
    @EnvironmentObject var manage : HttpAuth
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @GestureState private var dragOffset = CGSize.zero
    
    
    
    fileprivate func createContent() -> some View {
        
        GeometryReader { proxy in
            
            VStack{
                
                ZStack(alignment: .top){
                    
                    Color.background
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(self.manage.item) { landmark in
                            GeometryReader {geometry in Barcode(name: landmark.name, price: landmark.price)
                                .listRowBackground(Color.clear)
                            }.frame(height: 90)
                            
                            
                        }.frame( minWidth:360)
                            
                        .padding(.top , 50)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 160.0)
                        
                        
                        
                    }.frame( minWidth:400, minHeight: 200, maxHeight: 600).offset(y: 260)
                    
                    
                    
                    CBScanner(supportBarcode: [.qr, .code128, .ean13, .ean8])
                        .interval(delay: 5.0)
                        .found{
                            self.manage.checkBarcode(barcode: $0)
                            print($0)
                            self.barcodeValue = $0
                    }
                    .simulator(mockBarCode: "MOCK BARCODE DATA 1234567890")
                    .torchLight(isOn: self.torceIsOn)
                    .cornerRadius(10)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .topLeading).modifier(FormModifier()).offset(y:40)
                    
                    
                    
                    
                    HStack(alignment: .top, spacing: 0.0) {
                        Button(action : {
                            self.mode.wrappedValue.dismiss()
                        }){
                            CircleButton(icon:"arrow.left", color: Color.background) .neumorphicButton()
                        }
                        
                        
                        Spacer()
                        
                    }.animation(.spring()).padding(.leading,proxy.safeAreaInsets.leading+20).padding(.bottom, proxy.safeAreaInsets.top)
                    
                    
                }.navigationBarBackButtonHidden(true)
                
                
                ZStack() {
                    HStack {
                        
                        Rectangle()
                            .foregroundColor(Color.clear)
                            .frame(width: 20, height: 20)
                            .padding(.leading)
                            .frame(maxWidth: .infinity)
                            .frame(height: 120,alignment: .bottom)
                            .background(Color.white)
                            //.cornerRadius(35)
                            .clip(shouldCurve: true) .rotationEffect(.degrees(-180)).shadow(color: Color("buttonShadow"), radius: 20, x: 0, y: 20)
                        
                    }
                    
                    
                    Button(action : {
                        self.simulatePayment()
                    }){
                        ZStack{
                            Rectangle().frame(width: 350, height: 60).cornerRadius(35).foregroundColor(Color.clear)
                            
                            HStack{
                                Text("Pay").fontWeight(.bold).font(.system(size: 30)).foregroundColor(Color.black)
                                Image(systemName: "creditcard.fill").resizable().foregroundColor(Color.black).frame(width: 30.0, height: 25.0)                                                                               }
                        }.padding(.bottom, -15).shadow(color: Color("buttonShadow"), radius: 20, x: 0, y: 20)
                        
                    }.animation(.spring())
                    
                }
            }
            
            
            
        }.gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
            
            if(value.startLocation.x < 20 && value.translation.width > 100) {
                self.mode.wrappedValue.dismiss()
            }
            
        })).navigationBarBackButtonHidden(true).background(Color.background.edgesIgnoringSafeArea(.all)).edgesIgnoringSafeArea(.bottom).blur(radius: self.isSendingPending ? 7 : 0).overlay(
            VStack{
                if self.isSendingPending {
                    createPopupContent()
                } else {
                    EmptyView()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background( self.isSendingPending ? Color.background.opacity(0.3) : .clear)
        )
        
        
    }
    
    fileprivate func createPopupContent() -> some View {
        return VStack {
            if paymentSent{
                self.okView.transition(.hearbeat)
                Text( "Success!").foregroundColor(.gray).padding()
            } else {
                self.loadingView.frame(width: 50, height: 50).transition(.scale)
                Text( "Validating...").foregroundColor(.gray).padding()
            }
        }.frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.width * 0.4)
            .padding()
            .background(Color.background.opacity(0.7))
            .cornerRadius(20)
            .shadow(color: Color("button").opacity(0.3), radius: 20, x: 0, y: 10)
            .transition(.move(edge: .bottom))
    }
    
    
    fileprivate func simulatePayment() {
        print(!self.manage.item.isEmpty)
        if(!self.manage.item.isEmpty){
            self.isSendingPending = true
            self.manage.set_reciept()
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            withAnimation {
                self.paymentSent = true
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                withAnimation {
                    self.isSendingPending = false
                    self.paymentSent = false
                    self.mode.wrappedValue.dismiss()
                    self.manage.item=[]
                }
            }
        }
        
        }
    }
    
    
    
    var body: some View {
        SubscriptionView(content: createContent(), publisher: NotificationCenter.keyboardPublisher) { frame in
            withAnimation {
                self.formOffset = frame.height > 0 ? -200 : 0
            }
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView().environmentObject(HttpAuth())
    }
}

