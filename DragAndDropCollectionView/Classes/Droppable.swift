//
//  KDDroppable.swift
//
//  Created by Paweł Rup on 18.10.2017.
//  Copyright © 2017 lobocode. All rights reserved.
//

import UIKit

@objc internal protocol Droppable {
    func canDrop(at rect: CGRect) -> Bool
    func willMove(item: Any, in rect: CGRect)
    func didMove(item: Any, in rect: CGRect)
    func didMoveOut(item: Any)
    func drop(dataItem item: Any, at rect: CGRect)
    func dropDestinationRect() -> CGRect
}
