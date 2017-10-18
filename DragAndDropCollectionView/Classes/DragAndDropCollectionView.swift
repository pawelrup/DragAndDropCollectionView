//
//  DragAndDropUICollectionView.swift
//
//  Created by Paweł Rup on 18.10.2017.
//  Copyright © 2017 lobocode. All rights reserved.
//

import UIKit

@objc public protocol DragAndDropCollectionViewDataSource : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, indexPathFor dataItem: Any) -> IndexPath?
    func collectionView(_ collectionView: UICollectionView, dataItemFor indexPath: IndexPath) -> Any
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFrom formIndexPath: IndexPath, to toIndexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem : Any, atIndexPath indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAt indexPath: IndexPath)
    
}

public class DragAndDropCollectionView: UICollectionView {
    
    private (set) var currentInRect : CGRect?
    private (set) var animating: Bool = false
    private (set) var paging : Bool = false
    private (set) var draggingPathOfCellBeingDragged : IndexPath?
    
    private var isHorizontal : Bool {
        return (self.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .horizontal
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        for case let cell as UICollectionViewCell in subviews {
            cell.isHidden = indexPath(for: cell) == draggingPathOfCellBeingDragged
        }
    }
    
    private func indexPath(for cellOverlappingRect: CGRect) -> IndexPath? {
        
        var overlappingArea : CGFloat = 0.0
        var cellCandidate : UICollectionViewCell?
        
        
        let visibleCells = self.visibleCells
        if visibleCells.count == 0 {
            return IndexPath(row: 0, section: 0)
        }
        
        if isHorizontal && cellOverlappingRect.origin.x > contentSize.width ||
            !isHorizontal && cellOverlappingRect.origin.y > contentSize.height {
            
            return IndexPath(row: visibleCells.count - 1, section: 0)
        }
        
        for visible in visibleCells {
            let intersection = visible.frame.intersection(cellOverlappingRect)
            if (intersection.width * intersection.height) > overlappingArea {
                overlappingArea = intersection.width * intersection.height
                cellCandidate = visible
            }
        }
        
        if let cellRetrieved = cellCandidate {
            return indexPath(for: cellRetrieved)
        }
        return nil
    }
    
    private func checkForEdgesAndScroll(with rect: CGRect) -> Void {
        if paging {
            return
        }
        
        let currentRect = CGRect(x: contentOffset.x,
                                 y: contentOffset.y,
                                 width: bounds.size.width,
                                 height: bounds.size.height)
        var rectForNextScroll: CGRect = currentRect
        
        if isHorizontal {
            
            let leftBoundary = CGRect(x: -30.0,
                                      y: 0.0,
                                      width: 30.0,
                                      height: frame.size.height)
            let rightBoundary = CGRect(x: frame.size.width,
                                       y: 0.0,
                                       width: 30.0,
                                       height: frame.size.height)
            
            if rect.intersects(leftBoundary) {
                rectForNextScroll.origin.x -= bounds.size.width * 0.5
                if rectForNextScroll.origin.x < 0 {
                    rectForNextScroll.origin.x = 0
                }
            }
            else if rect.intersects(rightBoundary) {
                rectForNextScroll.origin.x += bounds.size.width * 0.5
                if rectForNextScroll.origin.x > contentSize.width - bounds.size.width {
                    rectForNextScroll.origin.x = contentSize.width - bounds.size.width
                }
            }
            
        } else { // is vertical
            
            let topBoundary = CGRect(x: 0.0,
                                     y: -30.0,
                                     width: frame.size.width,
                                     height: 30.0)
            let bottomBoundary = CGRect(x: 0.0,
                                        y: frame.size.height,
                                        width: frame.size.width,
                                        height: 30.0)
            
            if rect.intersects(topBoundary) {
                
            } else if rect.intersects(bottomBoundary) {
                
            }
        }
        
        if !currentRect.equalTo(rectForNextScroll) {
            paging = true
            scrollRectToVisible(rectForNextScroll, animated: true)
            
            let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.paging = false
            }
        }
    }
}

// MARK: - Draggable
extension DragAndDropCollectionView: Draggable {
    func canDrag(at point: CGPoint) -> Bool {
        if dataSource is DragAndDropCollectionViewDataSource {
            return indexPathForItem(at: point) != nil
        }
        return false
    }
    
    func representationImage(at point: CGPoint) -> UIView? {
        
        guard let indexPath = indexPathForItem(at: point),
            let cell = cellForItem(at: indexPath) else {
                return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.isOpaque, 0)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(image: image)
        imageView.frame = cell.frame
        
        return imageView
    }
    
    func dataItem(at point: CGPoint) -> Any? {
        guard let indexPath = indexPathForItem(at: point),
            let dragDropDS = dataSource as? DragAndDropCollectionViewDataSource else {
                return nil
        }
        return dragDropDS.collectionView(self, dataItemFor: indexPath)
    }
    
    func startDragging(at point: CGPoint) {
        draggingPathOfCellBeingDragged = indexPathForItem(at: point)
        reloadData()
    }
    
    func stopDragging() {
        if let idx = draggingPathOfCellBeingDragged,
            let cell = cellForItem(at: idx) {
            cell.isHidden = false
        }
        draggingPathOfCellBeingDragged = nil
        reloadData()
    }
    
    func drag(dataItem item: Any) {
        guard let dragDropDataSource = dataSource as? DragAndDropCollectionViewDataSource,
            let existngIndexPath = dragDropDataSource.collectionView(self, indexPathFor: item) else {
                return
        }
        dragDropDataSource.collectionView(self, deleteDataItemAt: existngIndexPath)
        animating = true
        performBatchUpdates({ () -> Void in
            self.deleteItems(at: [existngIndexPath])
        }, completion: { complete -> Void in
            self.animating = false
            self.reloadData()
        })
    }
}

// MARK: - Droppable
extension DragAndDropCollectionView: Droppable {
    func canDrop(at rect: CGRect) -> Bool {
        return indexPath(for: rect) != nil
    }
    
    func willMove(item: Any, in rect: CGRect) {
        let dragDropDataSource = dataSource as! DragAndDropCollectionViewDataSource // its guaranteed to have a data source
        
        if let _ = dragDropDataSource.collectionView(self, indexPathFor: item) { // if data item exists
            return
        }
        
        if let indexPath = indexPath(for: rect) {
            
            dragDropDataSource.collectionView(self, insertDataItem: item, atIndexPath: indexPath)
            
            draggingPathOfCellBeingDragged = indexPath
            
            animating = true
            
            performBatchUpdates({ () -> Void in
                self.insertItems(at: [indexPath])
            }, completion: { complete -> Void in
                self.animating = false
                if self.draggingPathOfCellBeingDragged == nil {
                    self.reloadData()
                }
            })
        }
        currentInRect = rect
    }
    
    func didMove(item: Any, in rect: CGRect) {
        let dragDropDS = self.dataSource as! DragAndDropCollectionViewDataSource
        
        if  let existingIndexPath = dragDropDS.collectionView(self, indexPathFor: item),
            let indexPath = self.indexPath(for: rect) {
            
            if indexPath.item != existingIndexPath.item {
                dragDropDS.collectionView(self, moveDataItemFrom: existingIndexPath, to: indexPath)
                animating = true
                performBatchUpdates({ () -> Void in
                    self.moveItem(at: existingIndexPath, to: indexPath)
                }, completion: { (finished) -> Void in
                    self.animating = false
                    self.reloadData()
                })
                self.draggingPathOfCellBeingDragged = indexPath
            }
        }
        
        var normalizedRect = rect
        normalizedRect.origin.x -= contentOffset.x
        normalizedRect.origin.y -= contentOffset.y
        currentInRect = normalizedRect
        checkForEdgesAndScroll(with: normalizedRect)
    }
    
    func didMoveOut(item: Any) {
        guard let dragDropDataSource = self.dataSource as? DragAndDropCollectionViewDataSource,
            let existngIndexPath = dragDropDataSource.collectionView(self, indexPathFor: item) else {
                return
        }
        dragDropDataSource.collectionView(self, deleteDataItemAt: existngIndexPath)
        animating = true
        performBatchUpdates({ () -> Void in
            self.deleteItems(at: [existngIndexPath])
        }, completion: { (finished) -> Void in
            self.animating = false;
            self.reloadData()
        })
        
        if let idx = draggingPathOfCellBeingDragged, let cell = cellForItem(at: idx) {
            cell.isHidden = false
        }
        
        draggingPathOfCellBeingDragged = nil
        currentInRect = nil
    }
    
    func drop(dataItem item: Any, at rect: CGRect) {
        if let index = draggingPathOfCellBeingDragged,
            let cell = cellForItem(at: index), cell.isHidden {
            
            cell.alpha = 1.0
            cell.isHidden = false
        }
        currentInRect = nil
        draggingPathOfCellBeingDragged = nil
        reloadData()
    }
    
    func dropDestinationRect() -> CGRect {
        if let indexPath = draggingPathOfCellBeingDragged, let attributes = layoutAttributesForItem(at: indexPath) {
            return attributes.frame
        }
        return .zero
    }
}
