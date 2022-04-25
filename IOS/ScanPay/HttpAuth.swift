//
//  HttpAuth.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import KeychainSwift
import CryptoKit
import AudioToolbox


class HttpAuth: ObservableObject {
    
    
    
    
    
    var didChange = PassthroughSubject<HttpAuth, Never>()
    @Published var enteredPin = "" {
         didSet {
             if enteredPin.count == 4 {
                addAccount(email: email, password: password, name: name, phone: phone, code:enteredPin )
                
             } else if enteredPin.count >= 4 {
                 enteredPin = ""
                 AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { return }
             }
         }
     }
    
    @Published var sendDataToNewAccaunt = false {
        didSet {
            didChange.send(self)
        }
    }
    
    
    
    @Published var emailNew = false {
        didSet {
            didChange.send(self)
        }
    }
    @Published var authenticated = false {
        didSet {
            didChange.send(self)
        }
    }
    var dsnvjksnv = 2
    
    
    @Published var errorsWithNews : Bool = false{
        didSet {
            didChange.send(self)
        }
    }
    
    @Published var errorsWithAccount : Bool = false{
           didSet {
               didChange.send(self)
           }
       }
    
    @Published var errors : Bool = false{
        didSet {
            didChange.send(self)
        }
    }
    
    @Published var errorsNewAccount : Bool = false{
           didSet {
               didChange.send(self)
           }
       }
    
    
    @Published var item : [ItemTovar] = []{
        didSet {
            didChange.send(self)
        }
    }
    @Published var reciept : [Reciped] = []{
        didSet {
            didChange.send(self)
        }
    }
    
    @Published var news : [News] = []{
        didSet {
            didChange.send(self)
        }
    }
    
    @Published var errorString : String = ""{
        didSet {
            didChange.send(self)
        }
    }
    
    
    @Published var user : UserInfo = UserInfo(barcode: 00000, name: "Loading ...", phone: "Loading ...", email: "Loading ...", points: 0){
        didSet {
            didChange.send(self)
        }
    }
    
    init(){
        self.authenticated = UserDefaults.standard.bool(forKey: "authenticated")
        self.token = UserDefaults.standard.string(forKey: "token") ?? ""
    }
    
    
    
    @Published var token = ""
    @Published var defaults = UserDefaults.standard
    @Published var email = ""
    @Published var phone = ""
    @Published var name = ""
    @Published var password = ""
    
    
    
    private func hashPassword(_ password: String, reset: Bool = false) -> String {
        let salt = "scanpay"
        
        guard let data = "\(password)\(salt)".data(using: .utf8) else { return "" }
        let digest = SHA256.hash(data: data)
        return digest.map{String(format: "%02hhx", $0)}.joined()
    }
    
    
    
    func checkDetails(username : String, password : String )  {
        guard let url = URL(string:  "http://deddc061.ngrok.io/login") else {
            self.errors = true
            return}
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        let bodyData = String( format: "email=%@&password=%@" ,username,hashPassword(password) )
        request.httpBody = bodyData.data(using: .utf8)
        
        
        /*
         request.httpBody = finalBody
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         
         */
        
        URLSession.shared.dataTask(with: request ) {
            (data , ressponse , error) in
            guard let data = data else {
                
                return}
            
            if let httpResponse = ressponse as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print(httpResponse.statusCode)
                }
                else {self.errors = true
                    return}
            }
            else{return}
            
            if (error != nil) {
                return
            }
            let finalData = try! JSONDecoder().decode(ServerMessage.self, from: data)
            
            if finalData.status == "ok" {
                DispatchQueue.main.async {
                    self.token = finalData.message
                    self.authenticated = true
                    self.defaults.set(true, forKey: "authenticated")
                    self.defaults.set(self.token,forKey: "token")
                }
                
            }
            
        }.resume()
        
    }
    
    func addAccount(email : String, password : String , name : String, phone: String, code : String )  {
        self.errorString = ""
        self.errorsNewAccount = false
        
        guard let url = URL(string:  "http://deddc061.ngrok.io/add_account") else {
            DispatchQueue.main.async {
            self.errorString = "Problem with Server"
            self.errorsNewAccount = true
            }
            return}
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        let bodyData = String(format: "code=%@&email=%@&password=%@&name=%@&phone=%@" ,code,email,hashPassword(password),name,phone)
        request.httpBody = bodyData.data(using: .utf8)
        
        
        URLSession.shared.dataTask(with: request ) {
            (data , ressponse , error) in
            guard let data = data else {DispatchQueue.main.async {
                self.errorString = "Problem with Server"
                self.errorsNewAccount = true
                }
                
                return}
            
             DispatchQueue.main.async {
            if let httpResponse = ressponse as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print(httpResponse.statusCode)
                }
                else { if( 420 == httpResponse.statusCode) {
                    self.errorString = "Code is invalid"
                    }
                    if(500...599).contains(httpResponse.statusCode) {
                         self.errorString = "Problem with Server"
                    }
                    self.errorString = "Problem with Date"
                    self.errorsNewAccount = true
                    return}
            }
            else{self.errorString = "Problem with Server"
                self.errorsNewAccount = true
                return}}
            
            if (error != nil) {
                DispatchQueue.main.async {
                self.errorString = "Problem with Server"
                self.errorsNewAccount = true
                }
            }
            let finalData = try! JSONDecoder().decode(ServerMessage.self, from: data)
            
            if finalData.status == "ok" {
                DispatchQueue.main.async {
                    self.emailNew = false
                    self.token = finalData.message
                    self.authenticated = true
                    self.defaults.set(self.token,forKey: "token")
                                UserDefaults.standard.set(true, forKey: "authenticated")
                                self.defaults.set(true, forKey: "authenticated")}
                       
                    
            }
                
            
            
        }.resume()
        
    }
    
    func checkeEmail(email : String) {
         guard let url = URL(string: "http://deddc061.ngrok.io/check_email") else {
             print("dfdfd")
             return}
         
         
         
         var request = URLRequest(url: url)
         request.httpMethod = "POST"

         
         
         let bodyData = String( format: "email=%@" ,email )
         request.httpBody = bodyData.data(using: .utf8)
         
         
         URLSession.shared.dataTask(with: request ) {
             (data , ressponse , error) in
             guard let data = data else {
                 
                 return}
             
             
             
             if (error != nil) {
                 return
             }
             if let httpResponse = ressponse as? HTTPURLResponse {
                 if(200...299).contains(httpResponse.statusCode) {
                     DispatchQueue.main.async {
                    self.emailNew = true
                    }
                     print(httpResponse.statusCode)
                 }
                 else {DispatchQueue.main.async {
                    self.errors = true
                    return}}
             }
             else{return}

             
         }.resume()
         
     }
    
    func checkBarcode(barcode : String) {
        guard let url = URL(string: "http://deddc061.ngrok.io/barcode") else {
            print("dfdfd")
            return}
        
        
        
        print(barcode)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(defaults.string(forKey: "token") ?? token, forHTTPHeaderField: "authorization")
        
        
        let bodyData = String( format: "barcode=%@" ,barcode )
        request.httpBody = bodyData.data(using: .utf8)
        
        
        URLSession.shared.dataTask(with: request ) {
            (data , ressponse , error) in
            guard let data = data else {
                
                return}
            
            
            
            if (error != nil) {
                return
            }
            if let httpResponse = ressponse as? HTTPURLResponse {
                if(200...299).contains(httpResponse.statusCode) {
                    print(httpResponse.statusCode)
                }
                else {self.errors = true
                    return}
            }
            else{return}
            
            
            
            print(data)
            
            
            let finalData = try! JSONDecoder().decode(ItemTovar.self, from: data)
            
            print (finalData)
            
            DispatchQueue.main.async {   // <====
                self.item.insert(finalData , at : 0)
                
            }
            print(self.item)
            
            
        }.resume()
        
    }
    
    func set_reciept() {
        guard let url = URL(string: "http://deddc061.ngrok.io/setreceipt") else {
            self.errors = true
            return}
        
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd.MM.yyyy HH:mm:ss"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(defaults.string(forKey: "token") ?? token, forHTTPHeaderField: "authorization")
        let date = Date()
        print(dateFormatterGet.string(from: date) )
        var barcode = ""
        var sum = 0.00
        
        for it in item{
            barcode += String(it.bordercode)
            barcode += " "
            sum += it.price
        }
        
        print(barcode)
        print(sum)
        
        let bodyData = String( format: "barcode=%@&&sum=%@&&date=%@", barcode,String(sum),dateFormatterGet.string(from: date) )
        request.httpBody = bodyData.data(using: .utf8)
        
        
        URLSession.shared.dataTask(with: request ) {
            (data , ressponse , error) in
            guard let data = data else {
                
                return}
            
            
            
            if (error != nil) {
                return
            }
            if let httpResponse = ressponse as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print(httpResponse.statusCode)
                }
                else {return}
            }
            else{return}
            
            
        }.resume()
        
    }
    
    
    
    func get_reciept() {
        
        print(self.errors)
         DispatchQueue.main.async { self.errors = false }
        
        dsnvjksnv+=1
        
        guard let url = URL(string: "http://deddc061.ngrok.io/receipt") else {
           DispatchQueue.main.async { self.errors = true }
            return}
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(defaults.string(forKey: "token") ?? token, forHTTPHeaderField: "authorization")
        
        
        URLSession.shared.dataTask(with: request ) {
            (data , ressponse , error) in
            guard let data = data else {
                DispatchQueue.main.async { self.errors = true }
                return}
            
            if (error != nil) {
                return
            }
            if let httpResponse = ressponse as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    if httpResponse.statusCode == 225{
                        return
                    }
                }
                else { DispatchQueue.main.async { print(1)
                    self.errors = true }
                    return}
            }
            else{return}
            
            
            
            print(data)
            
            
            let jsonDecoder = JSONDecoder()
            do {
                let finalData = try jsonDecoder.decode(Entry.self, from: data)
                DispatchQueue.main.async {
                    self.reciept = []
                    for receipt in finalData.receipt {
                        self.reciept.insert(receipt.value , at : 0)
                    }
                    
                }
            } catch {
                print(error)
            }
            
            
            
            
            
            
        }.resume()
        
    }
    
    
    func get_news() {

            
        guard let url = URL(string: "http://deddc061.ngrok.io/get_news") else {DispatchQueue.main.async { self.errorsWithNews = true }
            return}
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(defaults.string(forKey: "token") ?? token, forHTTPHeaderField: "authorization")
        
        
        URLSession.shared.dataTask(with: request ) {
            (data , ressponse , error) in
            guard let data = data else {
                DispatchQueue.main.async { self.errorsWithNews = true }
                return}
            
            if (error != nil) {
                DispatchQueue.main.async { self.errorsWithNews = true }
                return
            }
            if let httpResponse = ressponse as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print(httpResponse.statusCode)
                }
                else {
                    DispatchQueue.main.async {print(1)
                        self.errorsWithNews = true }
                    return}
            }
            else{
                DispatchQueue.main.async { self.errorsWithNews = true }
                return}
            
            
            
            print(data)
            
            
            let jsonDecoder = JSONDecoder()
            do {
                let finalData = try jsonDecoder.decode(Entry1.self, from: data)
                DispatchQueue.main.async {
                    self.news = []
                    for news_item in finalData.news {
                        self.news.insert(news_item.value , at : 0)
                    }
                    
                }
            } catch {
               DispatchQueue.main.async { self.errorsWithNews = true }
            }
            
            
        }.resume()
        
    }
    
    
    
    
    
    func get_user_info()  {
        print(self.errors)
    
        
        
        guard let url = URL(string: "http://deddc061.ngrok.io/user_info") else {
            DispatchQueue.main.async { self.errorsWithAccount = true }
            return}
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(defaults.string(forKey: "token") ?? token, forHTTPHeaderField: "authorization")
        
        
        URLSession.shared.dataTask(with: request ) {
            (data , ressponse , error) in
            guard let data = data else {
                DispatchQueue.main.async { self.errorsWithAccount = true }
                return}
            
            if (error != nil) {
                DispatchQueue.main.async { self.errorsWithAccount = true }
                return
            }
            if let httpResponse = ressponse as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                }
                else {
                    DispatchQueue.main.async { self.errorsWithAccount = true }
                    return}
            }
            else{
                DispatchQueue.main.async { self.errorsWithAccount = true }
                return}

            let jsonDecoder = JSONDecoder()
            do {
                let finalData = try jsonDecoder.decode(UserInfo.self, from: data)
                DispatchQueue.main.async {
                    self.user = finalData
                    
                    
                }
            } catch {
                DispatchQueue.main.async { self.errorsWithAccount = true }
            }
        
        }.resume()
        
    }
    
    
    
    func singOut() {
        DispatchQueue.main.async {
            UserDefaults.standard.set(false, forKey: "authenticated")
            self.authenticated = false
            
            
            
        }
        
        
        
    }
    
    
    
    
    
    
}
