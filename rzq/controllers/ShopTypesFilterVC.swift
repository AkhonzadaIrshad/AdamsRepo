//
//  ShopTypesFilterVC.swift
//  rzq
//
//  Created by Zaid najjar on 5/15/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol TypeListDelegate {
    func onClick(type : ShopType)
}

class ShopTypesFilterVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchField: MyUITextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    var latitude : Double?
    var longitude : Double?
    
    var items = [ShopType]()
    
    var delegate : TypeListDelegate?
    
    override func viewDidLoad() {
        
        self.items = Constants.getPlaces()
        
        super.viewDidLoad()
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchField.delegate = self
        
        self.tableView.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.onClick(type: self.items[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ShopTypeCell = tableView.dequeueReusableCell(withIdentifier: "shoptypecell", for: indexPath) as! ShopTypeCell
        
        let item = self.items[indexPath.row]
        
        cell.ivLogo.image = self.getShopImageByType(type: item.id ?? 0)
        cell.lblName.text = item.name ?? ""
        
        return cell
    }
    
    
    func getShopImageByType(type : Int) -> UIImage {
        switch type {
        case Constants.PLACE_BAKERY:
            return UIImage(named: "ic_place_bakery")!
        case Constants.PLACE_BOOK_STORE:
            return UIImage(named: "ic_place_book_store")!
        case Constants.PLACE_CAFE:
            return UIImage(named: "ic_place_cafe")!
        case Constants.PLACE_MEAL_DELIVERY:
            return UIImage(named: "ic_place_meal_delivery")!
        case Constants.PLACE_MEAL_TAKEAWAY:
            return UIImage(named: "ic_place_meal_takeaway")!
        case Constants.PLACE_PHARMACY:
            return UIImage(named: "ic_place_pharmacy")!
        case Constants.PLACE_RESTAURANT:
            return UIImage(named: "ic_place_restaurant")!
        case Constants.PLACE_SHOPPING_MALL:
            return UIImage(named: "ic_place_shopping_mall")!
        case Constants.PLACE_STORE:
            return UIImage(named: "ic_place_store")!
        case Constants.PLACE_SUPERMARKET:
            return UIImage(named: "ic_place_supermarket")!
        default:
            return UIImage(named: "ic_place_store")!
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension ShopTypesFilterVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.searchField {
            let maxLength = 20
            let currentString: NSString = textField.text as NSString? ?? ""
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if (newString.length >= 3) {
                self.items.removeAll()
                let arr = Constants.getPlaces().filter {
                    $0.name?.lowercased().range(of: newString.lowercased as String) != nil
                }
                self.items.append(contentsOf: arr)
                self.tableView.reloadData()
            }
            if (newString.length == 0) {
                self.items.removeAll()
                self.items = Constants.getPlaces()
                self.tableView.reloadData()
            }
            return newString.length <= maxLength
        }
        
        return false
    }
    
}
