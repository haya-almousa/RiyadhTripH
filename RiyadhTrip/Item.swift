//
//  Item.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
