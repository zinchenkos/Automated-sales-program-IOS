//
//  HomeList.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI



struct HomeList: View {
    
    var product = productData
    var receipt = receiptData
    @State var showContent = false
    @EnvironmentObject var manage : HttpAuth
    @State var showRefreshView: Bool = false
    @State var conCart:Bool = false
    @State var showAwards :Bool = false
    
    
    var body: some View {
        RefreshableList(showRefreshView: $showRefreshView, action:{
            self.manage.get_reciept()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showRefreshView = false
                
            }
        }){
            
            ScrollView(showsIndicators: false) {
                VStack {
                    
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("ScanPay")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                        }
                        Spacer()
                    }
                    .padding(.leading, 60.0)
                    
                    
                    
                    
                    HStack(spacing: 25){
                        
                        
                        NavigationLink(destination: ScanView().background(Color.background).transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))).environmentObject(self.manage)){
                            
                            HStack{
                                
                                VStack(alignment: .leading){
                                    
                                    Text("Start").fontWeight(.bold).font(.system(size: 22))
                                    
                                    Text("Shoping").fontWeight(.bold)
                                }
                                
                                Spacer(minLength: 0)
                                
                                Image(systemName:"play.fill").foregroundColor(.white).frame(width: 40.0, height: 40.0)
                                
                            }.padding()
                                .frame(width: (UIScreen.main.bounds.width - 70) / 2)
                                .background(Color.accent)
                                .cornerRadius(25)
                                .shadow(radius: 10)
                            
                            
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        Button(action: {self.showAwards.toggle()
                            
                        }) {
                            
                            
                            HStack{
                                
                                VStack(alignment: .leading){
                                    
                                    Text("Awards").fontWeight(.bold).font(.system(size: 22))
                                    
                                    Text("0/50").fontWeight(.bold)
                                }
                                
                                Spacer(minLength: 0)
                                
                                Image(systemName:"cube.fill").foregroundColor(.white).frame(width: 40.0, height: 40.0)
                                
                            }.padding()
                                .frame(width: (UIScreen.main.bounds.width - 70) / 2)
                                .background(Color.blue)
                                .cornerRadius(25)
                                .shadow(radius: 10)
                            
                        }.sheet(isPresented: self.$showAwards) { Awards()}
                        
                        
                        
                        
                        
                        
                    }.foregroundColor(.white)
                        .padding(.top,30)
                    
                   HStack(spacing: 25){
                    
                    Button(action: {self.conCart.toggle()
                        
                    }) {
                        
                        
                        HStack{
                            
                            VStack(alignment: .leading){
                                
                                Text("Сonnect").fontWeight(.bold).font(.system(size: 22))
                                
                                Text("to the shopping cart").fontWeight(.bold)
                            }
                            
                            Spacer(minLength: 0)
                            
                            Image(systemName:"radiowaves.right").foregroundColor(.white).frame(width: 40.0, height: 40.0)
                            
                            Image(systemName:"cart.fill").foregroundColor(.white).frame(width: 40.0, height: 40.0)
                            
                        }.padding()
                            .frame(width: (UIScreen.main.bounds.width - 45))
                            .background(Color("background4"))
                            .cornerRadius(25)
                            .shadow(radius: 10)
                        
                    }.foregroundColor(.white)
                        .padding(.top,5).sheet(isPresented: self.$conCart) { ConectToTheShopingCart()}
                    
                    }
                    Spacer()
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Лучшие Товары")
                                .font(.title)
                                .fontWeight(.heavy)
                        }
                        Spacer()
                    }.padding(.leading, 60.0)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 50.0) {
                            ForEach(self.product) { item in
                                Button(action: { }) {
                                    GeometryReader { geometry in
                                        ProductView(title: item.title,
                                                    price: item.price,
                                                    image: item.image,
                                                    color: item.color)
                                            .rotation3DEffect(Angle(degrees:
                                                Double(geometry.frame(in: .global).minX - 30) / -40), axis: (x: 0, y: 10.0, z: 0))
                                    }
                                }
                                    
                                .frame(width: 246, height: 340)
                                
                            }
                        }
                        .padding(.top , 30)
                        .padding(.horizontal, 30)
                        .padding(.leading, 30)
                        .padding(.bottom, 25.0)
                        
                        
                        
                    }
                    .padding(.top, -30.0)
                    
                    
                    VStack{
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Чеки")
                                    .font(.title)
                                    .fontWeight(.heavy)
                            }
                            Spacer()
                        }.padding(.leading, 60.0)
                        
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: -10.0) {
                                ForEach(self.manage.reciept) { items in
                                    Button(action: {}) {
                                        ReceiptView(data: items.date, price: items.sum)
                                        
                                    }
                                }
                            }.frame( minWidth:230, minHeight: 160)
                                .padding(.horizontal, 30)
                                .padding(.top, 10)
                                .padding(.bottom,10)
                            
                            
                            Spacer()
                            
                            
                        }.padding(.top, -20)
                    }
                    
                }
                
            }
            .padding(.horizontal, -20.0)
        }.alert(isPresented: self.$manage.errors, content: {
           Alert(title: Text("Error"), message: Text("Error with conection"))
        })
    }
}


#if DEBUG
struct HomeList_Previews: PreviewProvider {
    static var previews: some View {
        HomeList().environmentObject(HttpAuth())
    }
}
#endif

struct ProductView: View {
    
    var title = "Title"
    var price : Double = 150
    var image = "Illustration1"
    var color = Color("background3")
    
    var body: some View {
        return VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.gray)
                .padding(.leading)
                .padding(.top)
                .lineLimit(4)
            Text(String(format: "%.2f ₴", price))
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundColor(Color.gray)
                .padding(.top ,5)
                .padding(.leading)
                .lineLimit(4)
            
            Spacer()
            
            Image(image)
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 246, height: 150)
                .padding(.bottom, 30)
        }
            //.background(color)
            .cornerRadius(25)
            .frame(width: 246, height: 300)
            .modifier(FormModifier())
        //.shadow(color: color.opacity(0.5), radius: 20, x: 0, y: 10)
    }
}

struct ReceiptView: View {
    
    var data = "Title"
    var price : Double = 150
    
    var body: some View {
        return VStack {
            HStack {
                VStack(alignment: .center) {
                    Text(data)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("accent"))
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    Text(String(format:" Sum : %.2f ₴", price))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    
                    
                }
            }
            .padding(.horizontal)
            Spacer()
            
            
            
            
            
        }
        .frame(width: 230, height: 100)
            //.background(Color.black)
            .cornerRadius(10)
            .modifier(FormModifier())
    }
    /*
     return VStack(alignment: .leading) {
     Text(data)
     .font(.title)
     .fontWeight(.bold)
     .foregroundColor(.white)
     .padding(.leading)
     .padding(.top)
     .lineLimit(4)
     Text(String(format:" Sum : %.2f ₴", price))
     .font(.system(size: 18))
     .fontWeight(.bold)
     .foregroundColor(.white)
     .padding(.top ,5)
     .padding(.leading)
     .lineLimit(4)
     
     Spacer()
     
     }
     .cornerRadius(25)
     .frame(width: 246, height: 100)
     
     }*/
}

struct Product: Identifiable {
    var id = UUID()
    var title: String
    var price: Double
    var image: String
    var color: Color
}


struct Receipt: Identifiable {
    var id = UUID()
    var data: String
    var sum: Double
}

let productData = [
    Product(title: "Банан (кг)",
            price : 20.00,
            image: "Illustration1",
            color: Color("background3")),
    Product(title: "Coca - Сola 1л",
            price : 15.00,
            image: "Illustration2",
            color: Color("background4")),
    Product(title: "Heets",
            price : 50.00,
            image: "Illustration3",
            color: Color("background7")),
]

let receiptData = [
    Receipt(data: "21.05.2020", sum: 1000.00),
    Receipt(data: "10.05.2020", sum: 200.00)
]
