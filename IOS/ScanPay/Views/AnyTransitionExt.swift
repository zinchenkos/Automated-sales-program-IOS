//
//  AnyTransitionExt.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//

import SwiftUI

extension AnyTransition {
    static var hearbeat: AnyTransition {
        return AnyTransition.scale(scale: 1.7).combined(with: .scale(scale: 1))
    }
}

