//
//  KDDraggable.swift
//
//  Created by Paweł Rup on 18.10.2017.
//  Copyright © 2017 lobocode. All rights reserved.
//

import UIKit

@objc internal protocol Draggable {
    func canDrag(at point: CGPoint) -> Bool
    func representationImage(at point: CGPoint) -> UIView?
    func dataItem(at point: CGPoint) -> Any?
    func drag(dataItem item: Any)
    @objc optional func startDragging(at point: CGPoint)
    @objc optional func stopDragging()
}
