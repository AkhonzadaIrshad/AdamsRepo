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
        
        if (shop?.image?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(shop?.image ?? "")")
          self.ivLogo.kf.setImage(with: url)
        }else {
            self.ivLogo.image = self.getShopImageByType(type : self.shop?.type?.id ?? 0)
        }
       
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
    
    @IBAction func orderAction(_ sender: Any) {
        if (self.isLoggedIn()) {
            
                let model = OTWOrder()
                
            let shopData = DataShop(id: self.shop?.id ?? 0, name: self.shop?.name ?? "", address: self.shop?.address ?? "", latitude: self.shop?.latitude ?? 0.0, longitude: self.shop?.longitude ?? 0.0, phoneNumber: self.shop?.phoneNumber ?? "", workingHours: self.shop?.workingHours ?? "", image: self.shop?.image ?? "", rate: self.shop?.rate ?? 0.0, type: self.shop?.type ?? TypeClass(id: 0, name: ""))
                
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
