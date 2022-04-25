//
//  UpdateStore.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import Combine
import SwiftUI

class UpdateStore: ObservableObject {
    var willChange = PassthroughSubject<Void, Never>()
    
    var updates: [Update] {
        didSet {
            willChange.send()
        }
    }
    
    init(updates: [Update] = []) {
        self.updates = updates
    }
}
