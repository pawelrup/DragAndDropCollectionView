//
//  DataItem.swift
//
//  Created by Paweł Rup on 18.10.2017.
//  Copyright © 2017 lobocode. All rights reserved.
//

import UIKit

struct DataItem: Equatable {
    var indexes:    String = ""
    var colour:     UIColor = .clear
    init(text: String, colour: UIColor) {
        self.indexes = text
        self.colour = colour
    }
}

func ==(lhs: DataItem, rhs: DataItem) -> Bool {
    return lhs.indexes == rhs.indexes && lhs.colour == rhs.colour
}
