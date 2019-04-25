//
//  FilterSheet.swift
//  rzq
//
//  Created by Zaid najjar on 4/1/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import MaterialComponents
import Cosmos


protocol FilterSheetDelegate {
    func onApply(radius : Float, rating : Double, types : Int)
    func onClear()
}
class FilterSheet: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var sectionsCollection: UICollectionView!
    
    @IBOutlet weak var distanceSlider: UISlider!
    
    @IBOutlet weak var lblRange: UILabel!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    var delegate : FilterSheetDelegate?
    
    var items = [ShopType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.items = Constants.getPlaces()
        
        self.sectionsCollection.delegate = self
        self.sectionsCollection.dataSource = self
        self.sectionsCollection.reloadData()
        
    }
    
    @IBAction func onSlide(_ sender: UISlider) {
        if sender === self.distanceSlider {
            self.lblRange.text = "\("0") \("km".localized) - \(String(format: "%.0f", sender.value)) \("km".localized)"
        }
    }
    
    
    //collection delegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = items[indexPath.row].name ?? ""
        label.sizeToFit()
        return CGSize(width: label.frame.width + 10, height: 35.0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilterSectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filtersectioncell", for: indexPath as IndexPath) as! FilterSectionCell
        
        let item = self.items[indexPath.row]
        
        cell.lblContent.text = item.name ?? ""
        
        if (item.icChecked ?? false) {
            cell.borderView.backgroundColor = UIColor.processing
            cell.containerView.backgroundColor = UIColor.processing
            cell.lblContent.textColor = UIColor.white
        }else {
            cell.borderView.backgroundColor = UIColor.uncheckedView
            cell.containerView.backgroundColor = UIColor.uncheckedView
            cell.lblContent.textColor = UIColor.uncheckedText
        }
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.items[indexPath.row].icChecked = !(self.items[indexPath.row].icChecked ?? false)
        self.sectionsCollection.reloadData()
    }
    

    @IBAction func applyAction(_ sender: Any) {
        var sum = 0
        for item in self.items {
            sum = sum + (item.id ?? 0)
        }
        delegate?.onApply(radius: (self.distanceSlider.value * 1000.0), rating: self.ratingView.rating, types : sum)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearAction(_ sender: Any) {
        delegate?.onClear()
        self.dismiss(animated: true, completion: nil)
    }
}
