//
//  Helper.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import Foundation

struct ServerMessage: Decodable {
    let status, message: String
}


struct UserInfo: Codable {
    let barcode : CLong
    let name : String
    let phone : String
    let email: String
    let points : Int
}




struct ItemTovar: Decodable {
    let id_product_value : Int
    let name : String
    let bordercode :CLong
    let price : Double
    let photo : String
    let points : Int

    

    }

    extension ItemTovar: Identifiable {
    var id: Int { id_product_value }

}


struct Reciped: Codable {
    let id_check_value: Int
    let id_user: Int
    let sum: Double
    let date: String
}

extension Reciped: Identifiable {
   var id: Int { id_check_value }
}


struct Entry: Codable {
    let receipt: [String: Reciped]
}



struct News: Codable {
    let id_news: Int
    let header: String
    let text: String
    let date: String
}

extension News: Identifiable {
   var id: Int { id_news }
}


struct Entry1: Codable {
    let news: [String: News]
}




