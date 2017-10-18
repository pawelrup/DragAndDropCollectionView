//
//  KDDragAndDropManager .swift
//
//  Created by Paweł Rup on 18.10.2017.
//  Copyright © 2017 lobocode. All rights reserved.
//

import UIKit

public class DragAndDropManager: NSObject {
    
    private struct Bundle {
        var offset : CGPoint = .zero
        var sourceDraggableView : UIView
        var overDroppableView : UIView?
        var representationImageView : UIView
        var dataItem : Any
    }
    
    private var canvas: UIView
    private var views:  [UIView]
    private var longPressGestureRecogniser = UILongPressGestureRecognizer()
    private var bundle : Bundle?
    
    public init(canvas : UIView, collectionViews : [UIView]) {
        self.canvas = canvas
        self.views = collectionViews
        super.init()
        
        longPressGestureRecogniser.delegate = self
        longPressGestureRecogniser.minimumPressDuration = 0.2
        longPressGestureRecogniser.addTarget(self, action: #selector(updateForLongPress(_:)))
        self.canvas.addGestureRecognizer(longPressGestureRecogniser)
    }
    
    @objc private func updateForLongPress(_ recogniser : UILongPressGestureRecognizer) {
        guard let bundle = self.bundle else { return }
        
        let pointOnCanvas = recogniser.location(in: recogniser.view)
        let sourceDraggable = bundle.sourceDraggableView as! Draggable
        let pointOnSourceDraggable = recogniser.location(in: bundle.sourceDraggableView)
        
        switch recogniser.state {
        case .began:
            UIView.animate(withDuration: 0.1, animations: {
                bundle.representationImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
            canvas.addSubview(bundle.representationImageView)
            sourceDraggable.startDragging?(at: pointOnSourceDraggable)
            
        case .changed:
            var repImgFrame = bundle.representationImageView.frame
            repImgFrame.origin = CGPoint(x: pointOnCanvas.x - bundle.offset.x,
                                         y: pointOnCanvas.y - bundle.offset.y)
            bundle.representationImageView.frame = repImgFrame
            
            var overlappingArea: CGFloat = 0
            
            var mainOverView: UIView?
            
            for view in self.views where view is Draggable  {
                let viewFrameOnCanvas = convertToCanvas(rect: view.frame, from: view)
                let intersectionNew = bundle.representationImageView.frame.intersection(viewFrameOnCanvas).size
                
                if (intersectionNew.width * intersectionNew.height) > overlappingArea {
                    overlappingArea = intersectionNew.width * intersectionNew.height
                    mainOverView = view
                }
            }
            
            if let droppable = mainOverView as? Droppable {
                let rect = self.canvas.convert(bundle.representationImageView.frame, to: mainOverView)
                if droppable.canDrop(at: rect) {
                    if mainOverView != bundle.overDroppableView {
                        (bundle.overDroppableView as! Droppable).didMoveOut(item: bundle.dataItem)
                        droppable.willMove(item: bundle.dataItem, in: rect)
                        
                    }
                    self.bundle!.overDroppableView = mainOverView
                    droppable.didMove(item: bundle.dataItem, in: rect)
                }
            }
            
        case .ended:
            guard let droppable = bundle.overDroppableView as? Droppable else {
                UIView.animate(withDuration: 0.1, animations: {
                    bundle.representationImageView.transform = .identity
                    bundle.representationImageView.alpha = 1
                }, completion: { (_) in
                    bundle.representationImageView.removeFromSuperview()
                    sourceDraggable.stopDragging?()
                })
                return
            }
            let rect = bundle.overDroppableView!.convert(droppable.dropDestinationRect(), to: canvas)
            
            if bundle.sourceDraggableView != bundle.overDroppableView {
                
                sourceDraggable.drag(dataItem: bundle.dataItem)
                
                UIView.animate(withDuration: 0.1, animations: {
                    bundle.representationImageView.transform = .identity
                    bundle.representationImageView.frame.origin = rect.origin
                    bundle.representationImageView.alpha = 1
                }, completion: { (_) in
                    droppable.drop(dataItem: bundle.dataItem, at: rect)
                    bundle.representationImageView.removeFromSuperview()
                    sourceDraggable.stopDragging?()
                })
            } else {
                
                UIView.animate(withDuration: 0.1, animations: {
                    bundle.representationImageView.transform = .identity
                    bundle.representationImageView.frame.origin = rect.origin
                    bundle.representationImageView.alpha = 1
                }, completion: { (_) in
                    bundle.representationImageView.removeFromSuperview()
                    sourceDraggable.stopDragging?()
                })
            }
            
        default:
            break
        }
    }
    
    // MARK: Helper
    private func convertToCanvas(rect: CGRect, from view: UIView) -> CGRect {
        
        var r: CGRect = rect
        var v = view
        
        while v != self.canvas {
            if let sv = v.superview {
                r.origin.x += sv.frame.origin.x
                r.origin.y += sv.frame.origin.y
                v = sv
                continue
            }
            break
        }
        
        return r
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DragAndDropManager: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        for view in self.views where view is Draggable  {
            let draggable = view as! Draggable
            let touchPointInView = touch.location(in: view)
            guard draggable.canDrag(at: touchPointInView),
                let representation = draggable.representationImage(at: touchPointInView) else {
                    continue
            }
            representation.frame = canvas.convert(representation.frame, from: view)
            representation.alpha = 0.7
            let pointOnCanvas = touch.location(in: canvas)
            let offset = CGPoint(x: pointOnCanvas.x - representation.frame.origin.x,
                                 y: pointOnCanvas.y - representation.frame.origin.y)
            
            if let dataItem = draggable.dataItem(at: touchPointInView) {
                
                bundle = Bundle(offset: offset,
                                sourceDraggableView: view,
                                overDroppableView: view is Droppable ? view : nil,
                                representationImageView: representation,
                                dataItem: dataItem)
                return true
            }
        }
        return false
    }
}
