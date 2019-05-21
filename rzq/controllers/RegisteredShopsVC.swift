//
//  RegisteredShopsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class RegisteredShopsVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: EmptyView!
    
    @IBOutlet weak var btnMenu: UIButton!
    var items = [SubsDatum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 140.0

          self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.loadShops()
        // Do any additional setup after loading the view.
    }
    
    func loadShops() {
        ApiService.getMySubscriptions(Authorization: self.loadUser().data?.accessToken ?? "") { (response) in
            if (response.subsData?.count ?? 0 > 0) {
                self.emptyView.isHidden = true
                self.items.removeAll()
                self.items.append(contentsOf: response.subsData ?? [SubsDatum]())
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else {
                self.emptyView.isHidden = false
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell : ShopRegisterCell = tableView.dequeueReusableCell(withIdentifier: "shopregistercell", for: indexPath) as! ShopRegisterCell
        
        let item = self.items[indexPath.row]
        
        if (item.image?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(item.image ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }else {
            let url = URL(string: "\(Constants.IMAGE_URL)\(item.type?.image ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }
        
        
        cell.lblName.text = item.name ?? ""
        cell.lblAddress.text = item.address ?? ""
        
        cell.onCancel = {
            self.showLoading()
            ApiService.unsubscribeToShop(Authorization: self.loadUser().data?.accessToken ?? "", shopId: item.id ?? 0) { (response) in
                self.hideLoading()
                if (response.errorCode == 0) {
                    self.showBanner(title: "alert".localized, message: "unregistered_to_shop".localized, style: UIColor.SUCCESS)
                    self.loadShops()
                }else {
                    self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
                }
            }
        }
        
        return cell
    }
    
    
}
