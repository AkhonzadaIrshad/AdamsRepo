//
//  ShopDetailsSheet.swift
//  rzq
//
//  Created by Zaid najjar on 4/25/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol ShopSheetDelegate {
    func onOrder(order : OTWOrder)
    func onDetails(shopData : ShopData)
}
class ShopDetailsSheet: BaseVC {

    
    @IBOutlet weak var ivLogo: CircleImage!
    @IBOutlet weak var lblName: MyUILabel!
    @IBOutlet weak var lblDesc: MyUILabel!
    
    var shop : ShopData?
    
    var latitude : Double?
    var longitude : Double?
   
    var delegate : ShopSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblName.text = shop?.name ?? ""
        lblDesc.text = shop?.address ?? ""
        let url = URL(string: "\(Constants.IMAGE_URL)\(shop?.image ?? "")")
        ivLogo.kf.setImage(with: url)
    }
    
    
    @IBAction func orderAction(_ sender: Any) {
        if (self.isLoggedIn()) {
            
                let model = OTWOrder()
                
                let shopData = DataShop(id: self.shop?.id ?? 0, type: self.shop?.type ?? 0, rate: self.shop?.rate ?? 0.0, name: self.shop?.name ?? "", address: self.shop?.address ?? "", latitude: self.shop?.latitude ?? 0.0, longitude: self.shop?.longitude ?? 0.0, phoneNumber: self.shop?.phoneNumber ?? "", workingHours: self.shop?.workingHours ?? "", isOpen: self.shop?.isOpen ?? false, image: self.shop?.image ?? "")
                
                model.shop = shopData
                model.pickUpAddress = shop?.name
                model.pickUpLatitude = shop?.latitude
                model.pickUpLongitude = shop?.longitude
                
    
                self.delegate?.onOrder(order: model)
            
        }
    }
    
    @IBAction func detailsAction(_ sender: Any) {
        self.showLoading()
        ApiService.getShopDetails(id: shop?.id ?? 0, completion: { (response) in
           self.delegate?.onDetails(shopData: response.shopData!)
        })
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
