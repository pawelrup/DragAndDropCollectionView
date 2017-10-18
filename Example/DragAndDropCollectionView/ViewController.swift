//
//  ViewController.swift
//
//  Created by Paweł Rup on 18.10.2017.
//  Copyright © 2017 lobocode. All rights reserved.
//

import UIKit
import DragAndDropCollectionView

class ViewController: UIViewController {
    
    @IBOutlet weak var firstCollectionView: DragAndDropCollectionView!
    @IBOutlet weak var secondCollectionView: DragAndDropCollectionView!
    
    private var dragAndDropManager : DragAndDropManager?
    
    var lowercased: [DataItem] = [
        DataItem(text: "a", colour: .brown),
        DataItem(text: "b", colour: .brown),
        DataItem(text: "c", colour: .brown),
        DataItem(text: "d", colour: .brown),
        DataItem(text: "e", colour: .brown),
        DataItem(text: "f", colour: .brown),
        DataItem(text: "g", colour: .brown),
        DataItem(text: "h", colour: .brown),
        DataItem(text: "i", colour: .brown),
        DataItem(text: "j", colour: .brown),
        DataItem(text: "k", colour: .brown)
    ]
    
    var uppercased: [DataItem] = [
        DataItem(text: "A", colour: .gray),
        DataItem(text: "B", colour: .gray),
        DataItem(text: "C", colour: .gray),
        DataItem(text: "D", colour: .gray),
        DataItem(text: "E", colour: .gray),
        DataItem(text: "F", colour: .gray),
        DataItem(text: "G", colour: .gray),
        DataItem(text: "H", colour: .gray),
        DataItem(text: "I", colour: .gray),
        DataItem(text: "J", colour: .gray),
        DataItem(text: "K", colour: .gray)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dragAndDropManager = DragAndDropManager(canvas: view, collectionViews: [firstCollectionView, secondCollectionView])
    }
    
}

extension ViewController: UICollectionViewDelegate, DragAndDropCollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case firstCollectionView:
            return lowercased.count
        default:
            return uppercased.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        let dataItem: DataItem
        switch collectionView {
        case firstCollectionView:
            dataItem = lowercased[indexPath.row]
        default:
            dataItem = uppercased[indexPath.row]
        }
        cell.label.text = dataItem.indexes
        cell.backgroundColor = dataItem.colour
        return cell
    }
    
    // MARK : DragAndDropCollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, dataItemFor indexPath: IndexPath) -> Any {
        switch collectionView {
        case firstCollectionView:
            return lowercased[indexPath.item]
        default:
            return uppercased[indexPath.item]
        }
    }
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem: Any, atIndexPath indexPath: IndexPath) {
        guard let item = dataItem as? DataItem else { return }
        switch collectionView {
        case firstCollectionView:
            lowercased.insert(item, at: indexPath.item)
        default:
            uppercased.insert(item, at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAt indexPath: IndexPath) {
        switch collectionView {
        case firstCollectionView:
            lowercased.remove(at: indexPath.item)
        default:
            uppercased.remove(at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFrom fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        switch collectionView {
        case firstCollectionView:
            let item = lowercased[fromIndexPath.item]
            lowercased.remove(at: fromIndexPath.item)
            lowercased.insert(item, at: toIndexPath.item)
        default:
            let item = uppercased[fromIndexPath.item]
            uppercased.remove(at: fromIndexPath.item)
            uppercased.insert(item, at: toIndexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathFor dataItem: Any) -> IndexPath? {
        
        guard let candidate = dataItem as? DataItem else { return nil }
        
        let items: [DataItem]
        
        switch collectionView {
        case firstCollectionView:
            items = lowercased
        default:
            items = uppercased
        }
        
        for item: DataItem in items where item == candidate {
            guard let position = items.index(of: item) else { continue }
            let indexPath = IndexPath(item: position, section: 0)
            return indexPath
        }
        
        return nil
    }
}
