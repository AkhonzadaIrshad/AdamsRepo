//
//  AllShopsVC.swift
//  rzq
//
//  Created by Zaid Khaled on 2/12/20.
//  Copyright © 2020 technzone. All rights reserved.
//

import UIKit
import CoreLocation

protocol AllShopDelegate {
    func onSelect(shop : DataShop)
}
class AllShopsVC: BaseVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var ivBack: UIButton!
    
    @IBOutlet weak var collectionCategories: UICollectionView!
    
    @IBOutlet weak var tableShops: UITableView!
    
    var categories = [TypeClass]()
    
    var delegate : AllShopDelegate?
    
    var selectedIndex = 0
    
    @IBOutlet weak var fieldSearch: MyUITextField!
    
    var shops = [DataShop]() {
        didSet {
            if (shops.count > 0) {
                self.tableShops.restore()
            }else {
                self.tableShops.setEmptyView(title: "no_shops".localized, message: "no_shops_desc".localized, image: "bg_no_data")
            }
        }
    }
    
    var latitude : Double?
    var longitude : Double?
    
    var selectedCategory : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.fieldSearch.delegate = self
        
        if (self.isArabic()) {
            self.ivBack.setImage(UIImage(named: "ic_back_arabic"), for: .normal)
            self.collectionCategories.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            self.fieldSearch.textAlignment = .right
            
            self.collectionCategories.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            
        }
        
        self.latitude = UserDefaults.standard.value(forKey: Constants.LAST_LATITUDE) as? Double ?? 0.0
        self.longitude = UserDefaults.standard.value(forKey: Constants.LAST_LONGITUDE) as? Double ?? 0.0
        
//        self.latitude = 29.306856
//        self.longitude = 47.698692
        
        
        self.collectionCategories.delegate = self
        self.collectionCategories.dataSource = self
        
        self.tableShops.delegate = self
        self.tableShops.dataSource = self
        
        
        ApiService.getAllTypes { (response) in
            let category = TypeClass(id: 0, name: "all_shops".localized, image: "", selectedIcon: "", icon: "")
            category.isChecked = false
            
            self.categories.append(category)
            
            let datum = response.data ?? [TypeClass]()
            //            for cat in datum {
            //                if (cat.id == self.selectedCategory) {
            //                    cat.isChecked = true
            //                }
            //                self.categories.append(cat)
            //            }
            
            for var i in (0..<datum.count) {
                if (datum[i].id == self.selectedCategory) {
                    datum[i].isChecked = true
                    self.selectedIndex = i
                }
                self.categories.append(datum[i])
                
            }
            
            self.collectionCategories.reloadData()
            let index = IndexPath(row: self.selectedIndex, section: 0)
            self.collectionCategories.scrollToItem(at: index, at: .left, animated: false)
            self.loadShops(type: self.selectedCategory ?? 0, keyword: "")
        }
        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func searchAction(_ sender: Any) {
        
    }
    
    
    //collection delegates
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = self.categories[indexPath.row].name ?? ""
        label.sizeToFit()
        return CGSize(width: label.bounds.width + 8, height: self.collectionCategories.bounds.height)
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
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for cat in self.categories {
            cat.isChecked = false
        }
        self.categories[indexPath.row].isChecked = true
        self.selectedCategory = self.categories[indexPath.row].id ?? 0
        self.collectionCategories.reloadData()
        self.fieldSearch.text = ""
        self.loadShops(type: self.selectedCategory ?? 0, keyword: "")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AllTypeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllTypeCell", for: indexPath as IndexPath) as! AllTypeCell
        
        let category = self.categories[indexPath.row]
        
        if (self.isArabic()) {
            cell.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        
        cell.lblName.text = category.name ?? ""
        
        if (category.isChecked ?? false) {
            cell.viewLine.isHidden = false
            cell.lblName.textColor = UIColor.black
        }else {
            cell.viewLine.isHidden = true
            cell.lblName.textColor = UIColor.appLightGray
        }
        
        if (category.image?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(category.image ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }else {
            cell.ivLogo.image = UIImage(named: "type_holder")
        }
        
        return cell
        
    }
    
    
    //tableview delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AllShopCell = tableView.dequeueReusableCell(withIdentifier: "AllShopCell", for: indexPath as IndexPath) as! AllShopCell
        
        let shop = self.shops[indexPath.row]
        
        
        cell.lblShopName.text = shop.name ?? ""
        cell.lblShopAddress.text = shop.address ?? ""
        
        let myLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        let driverLatLng = CLLocation(latitude: shop.latitude ?? 0.0, longitude: shop.longitude ?? 0.0)
        let distanceInMeters = driverLatLng.distance(from: myLatLng)
        let distanceInKM = distanceInMeters / 1000.0
        let distanceStr = String(format: "%.2f", distanceInKM)
        
        cell.lblDistance.text = "\(distanceStr) \("km".localized)"
        
        if (shop.images?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(shop.images?[0] ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }else if (shop.type?.image?.count ?? 0 > 0){
            let url = URL(string: "\(Constants.IMAGE_URL)\(shop.type?.image ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }else {
            cell.ivLogo.image = UIImage(named: "ic_place_store")
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //go to delivery step 1
        let shop = self.shops[indexPath.row]
        self.delegate?.onSelect(shop: shop)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func loadShops(type : Int, keyword : String) {
        ApiService.getShopsPrioritySearch(keyword : keyword,latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: Float(Constants.DEFAULT_RADIUS), rating: 0, types: type) { (response) in
            self.shops.removeAll()
            self.shops.append(contentsOf: response.dataShops ?? [DataShop]())
            self.tableShops.reloadData()
        }
    }
    
    func getShopsByName(type : Int, keyword : String) {
        ApiService.getShopsByName(name: keyword, latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0, radius: Float(Constants.DEFAULT_RADIUS)) { (response) in
            self.shops.removeAll()
            self.shops.append(contentsOf: response.dataShops ?? [DataShop]())
            self.tableShops.reloadData()
        }
    }
    
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension AllShopsVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.fieldSearch) {
            let query = self.fieldSearch.text ?? ""
            if (query.count > 2) {
                //filter
                self.loadShops(type: self.selectedCategory ?? 0, keyword: query)
            }else {
                self.loadShops(type: self.selectedCategory ?? 0, keyword: "")
            }
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.fieldSearch) {
            
            if let text = textField.text,
                let textRange = Range(range, in: text) {
                let query = text.replacingCharacters(in: textRange,
                                                     with: string)
                
                if (query.count > 2) {
                    //filter
                    self.loadShops(type: self.selectedCategory ?? 0, keyword: query)
                }else {
                    self.loadShops(type: self.selectedCategory ?? 0, keyword: "")
                }
            }else {
                self.loadShops(type: self.selectedCategory ?? 0, keyword: "")
            }
            return true
        }
        return false
    }
}
