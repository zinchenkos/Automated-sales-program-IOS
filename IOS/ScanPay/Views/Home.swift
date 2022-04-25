//
//  Home.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
let screen = UIScreen.main.bounds


struct Home: View {
    
    @State var show = false
    @State var showProfile = false
    @State var showUpdate = false
    @EnvironmentObject var manage : HttpAuth
    
    
    var body: some View {
        
        NavigationView{
            
            
            ZStack(alignment: .top) {
                Color.background
                
                
                HomeList()
                    .blur(radius: show ? 20 : 0)
                    .animation(.default).environmentObject(self.manage)
                    .padding(.top, 60)
                
                
                
                
                HStack {
                    MenuButton(show: $show)
                        .offset(x: -40)
                    Spacer()
                    
                    MenuRight(show: $showProfile, showUpdate: $showUpdate)
                        .offset(x: -16).environmentObject(self.manage)
                }
                .offset(y: showProfile||showUpdate ? statusBarHeight : 80)
                .animation(.spring())
                
                MenuView(show: $show)
            }.padding(.top, statusBarHeight).background(Color.background.edgesIgnoringSafeArea(.all)).edgesIgnoringSafeArea(.all)
            
            
        }.background(Color.background.edgesIgnoringSafeArea(.all)).edgesIgnoringSafeArea(.top).onAppear(perform: self.manage.get_reciept )
        
        
        
    }
    
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(HttpAuth())
    }
}


struct MenuRow: View {
    
    var image = "creditcard"
    var text = "My Account"
    
    var body: some View {
        return HStack {
            Image(systemName: image)
                .imageScale(.large)
                .foregroundColor(Color("icons"))
                .frame(width: 32, height: 32)
            
            Text(text)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct Menu: Identifiable {
    var id = UUID()
    var title: String
    var icon: String
}

let menuData = [
    Menu(title: "My Account", icon: "person.crop.circle"),
    Menu(title: "Settings", icon: "gear"),
    Menu(title: "Billing", icon: "creditcard"),
    Menu(title: "Sign out", icon: "arrow.uturn.down")
]

struct MenuView: View {
    
    var menu = menuData
    @Binding var show: Bool
    @State var showSettings = false
    @EnvironmentObject var manage : HttpAuth
    
    var body: some View {
        return HStack {
            VStack(alignment: .leading) {
                ForEach(menu) { item in
                    if item.title == "Settings" {
                        Button(action: { self.showSettings.toggle() }) {
                            MenuRow(image: item.icon, text: item.title)
                                .sheet(isPresented: self.$showSettings) { Settings() }
                        }
                    } else if item.title == "Sign out"  {Button(action: {
                        self.manage.singOut()
                        print(UserDefaults.standard.bool(forKey: "authenticated"))
                    }) {
                        MenuRow(image: item.icon, text: item.title)}}
                    else {
                        MenuRow(image: item.icon, text: item.title)
                    }
                }
                Spacer()
            }
            .padding(.top, 20)
            .padding(30)
            .frame(minWidth: 0, maxWidth: 800)
            .background(Color("button"))
            .cornerRadius(30)
            .shadow(radius: 20)
            .rotation3DEffect(Angle(degrees: show ? 0 : 60), axis: (x: 0, y: 10.0, z: 0))
            .animation(.default)
            .offset(x: show ? 0 : -UIScreen.main.bounds.width)
            .onTapGesture {
                self.show.toggle()
            }
            Spacer()
        }
        .padding(.top, statusBarHeight)
        
    }
}

struct CircleButton: View {
    
    var icon = "person.crop.circle"
    var color = Color("button")
    
    var body: some View {
        return HStack {
            Image(systemName: icon)
                .foregroundColor(.primary)
        }
        .frame(width: 44, height: 44)
        .background(color)
        .cornerRadius(30)
        .shadow(color: Color("buttonShadow"), radius: 20, x: 0, y: 20)
    }
}

struct MenuButton: View {
    @Binding var show: Bool
    
    var body: some View {
        return ZStack(alignment: .topLeading) {
            Button(action: { self.show.toggle() }) {
                HStack {
                    Spacer()
                    
                    Image(systemName: "list.dash")
                        .foregroundColor(.primary)
                }
                .padding(.trailing, 18)
                .frame(width: 90, height: 60)
                .background(Color("button"))
                .cornerRadius(30)
                .shadow(color: Color("buttonShadow"), radius: 20, x: 0, y: 20)
            }
            Spacer()
        }
    }
}

struct MenuRight: View {
    
    @Binding var show: Bool
    @Binding var showUpdate : Bool
    @EnvironmentObject var manage : HttpAuth
    
    var body: some View {
        return ZStack(alignment: .topTrailing) {
            HStack {
                Button(action: {self.manage.get_user_info()
                    self.show.toggle()
                    print(self.manage.errors)
                }) {
                    CircleButton(icon: "person.crop.circle")
                }.sheet(isPresented: self.$show) {
                    ShowAccount().alert(isPresented: self.$manage.errorsWithAccount, content: {
                       Alert(title: Text("Error with connection"), message: Text("We can`t see now your account"))
                    }).environmentObject(self.manage) }
                Button(action: {self.manage.get_news()
                    self.showUpdate.toggle() }) {
                    CircleButton(icon: "bell")
                        .sheet(isPresented: self.$showUpdate) { UpdateList().alert(isPresented: self.$manage.errorsWithNews, content: {
                           Alert(title: Text("Error with connection"), message: Text("We can`t see now news"))
                        }).environmentObject(self.manage).background(Color.background.edgesIgnoringSafeArea(.all)).edgesIgnoringSafeArea(.top) }
                }
            }
            Spacer()
        }
    }
}
