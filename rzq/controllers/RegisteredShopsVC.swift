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
            self.items.removeAll()
            self.items.append(contentsOf: response.subsData ?? [SubsDatum]())
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell : ShopRegisterCell = tableView.dequeueReusableCell(withIdentifier: "shopregistercell", for: indexPath) as! ShopRegisterCell
        
        let item = self.items[indexPath.row]
        let url = URL(string: "\(Constants.IMAGE_URL)\(item.image ?? "")")
        cell.ivLogo.kf.setImage(with: url)
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
