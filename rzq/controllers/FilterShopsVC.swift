//
//  FilterShopsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/28/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import CoreLocation

protocol FilterListDelegate {
    func onClick(shop : DataShop)
}
class FilterShopsVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchField: MyUITextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    var latitude : Double?
    var longitude : Double?
    
    var items = [DataShop]()
    
    var delegate : FilterListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 71.0
        
        self.searchField.delegate = self

    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.onClick(shop: self.items[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ShopFilterCell = tableView.dequeueReusableCell(withIdentifier: "shopfiltercell", for: indexPath) as! ShopFilterCell
        
        let item = self.items[indexPath.row]
        
        
        let driverLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        let dropOffLatLng = CLLocation(latitude: item.latitude ?? 0.0, longitude: item.longitude ?? 0.0)
        let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
        let distanceInKM = distanceInMeters / 1000.0
        let distanceStr = String(format: "%.2f", distanceInKM)
        
        cell.lblName.text = "\(item.name ?? "")  (\(distanceStr) \("km".localized))"
        
        cell.lblAddress.text = item.address ?? ""
        
        return cell
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getShopsList(radius : Float, rating : Double, types : Int) {
        ApiService.getShops(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: radius, rating : rating, types : types) { (response) in
            self.items.removeAll()
            self.items.append(contentsOf: response.dataShops ?? [DataShop]())
            self.tableView.reloadData()
        }
    }
    
    func getShopsByName(name : String, latitude : Double, longitude: Double, radius : Float) {
        ApiService.getShopsByName(name: name, latitude: latitude, longitude: longitude, radius: radius) { (response) in
            self.items.removeAll()
            self.items.append(contentsOf: response.dataShops ?? [DataShop]())
            self.tableView.reloadData()
        }
    }
    
    
}

extension FilterShopsVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.searchField {
            let maxLength = 20
            let currentString: NSString = textField.text as NSString? ?? ""
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if (newString.length >= 3) {
                self.getShopsByName(name : newString as String, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: Float(Constants.DEFAULT_RADIUS))
            }
            if (newString.length == 0) {
                self.getShopsList(radius: Float(Constants.DEFAULT_RADIUS), rating: 0, types : 0)
            }
            return newString.length <= maxLength
        }
        
        return false
    }
    
}
