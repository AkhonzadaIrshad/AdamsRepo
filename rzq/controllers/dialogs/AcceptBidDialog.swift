//
//  AcceptBidDialog.swift
//  rzq
//
//  Created by Zaid najjar on 4/14/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import Cosmos
import CoreLocation
import MFSDK

protocol AcceptBidDelegate {
    func refreshNotifications()
    func onAccept()
}
class AcceptBidDialog: PaymentViewController, PaymentDelegate {
    
    @IBOutlet weak var ivLogo: CircleImage!
    @IBOutlet weak var lblDriverName: MyUILabel!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var lblMoney: MyUILabel!
    @IBOutlet weak var lblTime: MyUILabel!
    @IBOutlet weak var lblDistance: MyUILabel!
    @IBOutlet weak var lblOrdersCount: MyUILabel!
    @IBOutlet weak var lblOfferPrice: MyUILabel!
    
    @IBOutlet weak var vwCounter: RoundedView!
    @IBOutlet weak var lblCounter: UILabel!
    
    @IBOutlet weak var vwAccept: CardView!
    @IBOutlet weak var vwDecline: CardView!
    
    var deliveryId  : Int?
    var bidId : Int?
    var notificationId : Int?
    var item : DatumNot?
    
    var latitude : Double?
    var longitude : Double?
    var count = 0
    var delegate : AcceptBidDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rateView.isUserInteractionEnabled = false
        
    }
    
    func initData() {
        let dict = self.item?.data?.convertToDictionary()
        if (item?.type == Constants.BID_CREATED) {
            let driver = dict?["Driver"] as? String ?? ""
            let driverImage = dict?["DriverImage"] as? String ?? ""
            let driverRate = dict?["DriverRate"] as? Double ?? 0.0
            let price = dict?["Price"] as? Double ?? 0.0
            let time = dict?["Time"] as? Int ?? 0
            let distance = dict?["Distance"] as? Double ?? 0.0
            self.deliveryId = dict?["OrderId"] as? Int ?? 0
            self.bidId = dict?["Id"] as? Int ?? 0
            let orderCount = dict?["OrderCount"] as? Int ?? 0
            
            let url = URL(string: "\(Constants.IMAGE_URL)\(driverImage)")
            self.ivLogo.kf.setImage(with: url)
            
            self.lblDriverName.text = self.encryptDriverName(name:driver)
            self.rateView.rating = driverRate
            self.lblOfferPrice.text = "\(price) \("currency".localized)"
            self.lblMoney.text = "\(price) \("currency".localized)"
            if (time > 0) {
                self.lblTime.text = "\(time) \("hours".localized)"
            }else {
                self.lblTime.text = "asap".localized
            }
            
            self.lblDistance.text = "\(String(format: "%.2f", (distance))) \("km".localized)"
            self.lblOrdersCount.text = "\(orderCount) \("orders".localized)"
        }else if (item?.type == Constants.SERVICE_BID_CREATED) {
            let driver = dict?["ProviderName"] as? String ?? ""
            let driverImage = dict?["ProviderImage"] as? String ?? ""
            let driverRate = dict?["ProviderRate"] as? Double ?? 0.0
            let price = dict?["Price"] as? Double ?? 0.0
            let time = dict?["Time"] as? Int ?? 0
            let providerLatitude = dict?["Latitude"] as? Double ?? 0.0
            let providerLongitude = dict?["Longitude"] as? Double ?? 0.0
            self.deliveryId = dict?["OrderId"] as? Int ?? 0
            self.bidId = dict?["BidId"] as? Int ?? 0
            let orderCount = dict?["OrderCount"] as? Int ?? 0
            
            let url = URL(string: "\(Constants.IMAGE_URL)\(driverImage)")
            self.ivLogo.kf.setImage(with: url)
            
            self.lblDriverName.text = self.encryptDriverName(name:driver)
            self.rateView.rating = driverRate
            self.lblOfferPrice.text = "\(price) \("currency".localized)"
            self.lblMoney.text = "\(price) \("currency".localized)"
            if (time > 0) {
                self.lblTime.text = "\(time) \("hours".localized)"
            }else {
                self.lblTime.text = "asap".localized
            }
            
            let driverLatLng = CLLocation(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
            let dropOffLatLng = CLLocation(latitude: providerLatitude, longitude: providerLongitude)
            let distanceInMeters = dropOffLatLng.distance(from: driverLatLng)
            let distanceInKM = distanceInMeters / 1000.0
            let distanceStr = String(format: "%.2f", distanceInKM)
            
            self.lblDistance.text = "\(distanceStr) \("km".localized)"
            self.lblOrdersCount.text = "\(orderCount) \("orders".localized)"
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
        self.startCountDown(startedFrom: item?.createdDate)
    }
    
    func encryptDriverName(name: String) -> String {
        var stars = ""
        let count = name.count - 2
        for _ in 1...count {
            stars = "\(stars)*"
        }
        let firstChar = name.first!
        let lastChar = name.last!
        let final = "\(String(firstChar))\(stars)\(String(lastChar))"
        return final
    }
    
    func applyDeclineAction() {
        self.showLoading()
        ApiService.declineBid(Authorization: DataManager.loadUser().data?.accessToken ?? "", bidId: self.bidId ?? 0) { (response) in
            self.hideLoading()
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "bid_declined_successfully".localized, style: UIColor.SUCCESS)
                self.delegate?.refreshNotifications()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
    
    @IBAction func declineAction(_ sender: Any) {
        applyDeclineAction()
    }
    
    //    func deleteNotification() {
    //        ApiService.deleteNotification(Authorization: DataManager.loadUser().data?.accessToken ?? "", id: self.notificationId ?? 0) { (response) in
    //            self.showBanner(title: "alert".localized, message: "bid_declined_successfully".localized, style: UIColor.SUCCESS)
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
    //                self.dismiss(animated: true, completion: nil)
    //            })
    //        }
    //    }
    
    @IBAction func acceptAction(_ sender: Any) {
        self.applyAcceptBidAcion()
    }
    
    func applyAcceptBidAcion() {
        self.showLoading()
        ApiService.getDelivery(id: self.deliveryId ?? 0) { (response) in
            self.hideLoading()
            if (response.data?.paymentMethod == Constants.PAYMENT_METHOD_KNET) {
                let dict = self.item?.data?.convertToDictionary()
                let shopId = dict?["ShopId"] as? Int ?? 0
                if (shopId > 0 && response.data?.items?.count ?? 0 > 0) {
                    self.startPaymentProcess(orderId: self.deliveryId ?? 0)
                }else {
                    self.acceptBid()
                }
            }else {
                self.acceptBid()
            }
        }
    }
    func acceptBid() {
        self.showLoading()
        ApiService.acceptBid(Authorization: DataManager.loadUser().data?.accessToken ?? "", deliveryId: self.deliveryId ?? 0, bidId: self.bidId ?? 0) { (response) in
            self.hideLoading()
            if (response.errorCode == 0) {
                self.showBanner(title: "alert".localized, message: "bid_accepted_successfully".localized, style: UIColor.SUCCESS)
                self.delegate?.onAccept()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }else {
                self.showBanner(title: "alert".localized, message: response.errorMessage ?? "", style: UIColor.INFO)
            }
        }
    }
    
    func onPaymentSuccess(payment : PaymentStatusResponse) {
        self.showLoading()
        ApiService.createPaymentRecord(Authorization: DataManager.loadUser().data?.accessToken ?? "", orderId: self.deliveryId ?? 0, payment: payment) { (response) in
            self.acceptBid()
        }
        
    }
    
    func onPaymentFail() {
        // self.acceptBid()
    }
    
    
    func getTotal(items : [ShopMenuItem]) -> Double {
        var total = 0.0
        for item in items {
            let doubleQuantity = Double(item.count ?? 0)
            let doublePrice = item.price ?? 0.0
            total = total + (doubleQuantity * doublePrice)
        }
        return total
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func viewReviewsAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : ProviderRatingsVC = storyboard.instantiateViewController(withIdentifier: "ProviderRatingsVC") as! ProviderRatingsVC
        let dict = self.item?.data?.convertToDictionary()
        vc.providerId = dict?["ProviderId"] as? String ?? ""
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func startCountDown(startedFrom: String?) {
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        if let startedTime = startedFrom {
            initCounter(startedFrom: startedTime)
        } else {
            self.count = 0
        }
        
    }
    
    @objc func update() {
        let (minutes, seconds) = secondsToHoursMinutesSeconds(seconds: self.count)
        if(count > 0) {
            self.vwCounter.isHidden = false
            count = count - 1
            lblCounter.text = String(minutes) + ":" + String(seconds)
        } else {
            self.vwCounter.isHidden = true
            self.vwAccept.isUserInteractionEnabled = false
            self.vwAccept.backgroundColor = .lightGray
            self.vwDecline.isUserInteractionEnabled = false
            self.vwDecline.backgroundColor = .lightGray
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
      return (seconds / 60, (seconds % 60))
    }
    
    func initCounter(startedFrom: String) {
        let inFormatter = DateFormatter()
        inFormatter.locale = .current
        inFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"

        let outFormatter = DateFormatter()
        outFormatter.locale = .current
        outFormatter.dateFormat = "hh:mm:ss"

        let bidDate = inFormatter.date(from: startedFrom) ?? Date()
        let nowDate = Date()
        let intervalInMin = (nowDate.timeIntervalSince(bidDate) / 60)
        if intervalInMin > 5 {
            self.count = 0
        } else {
            self.count = 300 - Int(nowDate.timeIntervalSince(bidDate))
        }
    }
    
    
    func startPaymentProcess(orderId : Int) {
        self.showLoading()
        ApiService.getDelivery(id: orderId) { (response) in
            self.hideLoading()
            let orderCost = self.getTotal(items: response.data?.items ?? [ShopMenuItem]())
            
            let dict = self.item?.data?.convertToDictionary()
            let dlvrCost = dict?["Price"] as? Double ?? 0.0
            let deliveryCost = dlvrCost
            
            let knetCommission = App.shared.config?.configSettings?.KnetCommission ?? 0.0
            
            var items = response.data?.items ?? [ShopMenuItem]()
            
            let item = ShopMenuItem(id: 0, name: "delivery_cost", imageName: "", price: deliveryCost, shopMenuItemDescription: "", count: 1)
            let item2 = ShopMenuItem(id: 0, name: "knet_commission", imageName: "", price: knetCommission, shopMenuItemDescription: "", count: 1)
            
            items.append(item)
            items.append(item2)
            
            let total = orderCost + deliveryCost + knetCommission
            self.ammountToPay = Double(total)
            self.executePayment(paymentMethodId: 1)
        }
    }
    
    
}

class PaymentViewController: BaseVC {
    //MARK: Variables
    var paymentMethods: [MFPaymentMethod]?
    var ammountToPay: Double?
    
    func initiatePayment() {
        let request = generateInitiatePaymentModel()
        MFPaymentRequest.shared.initiatePayment(request: request, apiLanguage: .english, completion: { [weak self] (result) in
            switch result {
            case .success(let initiatePaymentResponse):
                self?.paymentMethods = initiatePaymentResponse.paymentMethods
            case .failure(let failError):
                print("Error: \(failError.errorDescription)")
            }
        })
    }
    
    private func generateInitiatePaymentModel() -> MFInitiatePaymentRequest {
        // you can create initiate payment request with invoice value and currency
        // let invoiceValue = Double(amountTextField.text ?? "") ?? 0
        // let request = MFInitiatePaymentRequest(invoiceAmount: invoiceValue, currencyIso: .kuwait_KWD)
        // return request
        
        let request = MFInitiatePaymentRequest()
        return request
    }
    
    func executePayment(paymentMethodId: Int) {
        let request = getExecutePaymentRequest(paymentMethodId: paymentMethodId)
        MFPaymentRequest.shared.executePayment(request: request, apiLanguage: .arabic) { [weak self] response, invoiceId  in
            switch response {
            case .success:
                print("Success")
            case .failure(let failError):
                print(failError.errorDescription)
            }
        }
    }
    
    private func getExecutePaymentRequest(paymentMethodId: Int) -> MFExecutePaymentRequest {
        let request = MFExecutePaymentRequest(invoiceValue: self.ammountToPay ?? 0, paymentMethod: 1)
        //request.userDefinedField = ""
        request.customerEmail = "a@b.com"// must be email
        request.customerMobile = ""
        request.customerCivilId = "Double("
        let address = MFCustomerAddress(block: "ddd", street: "sss", houseBuildingNo: "sss", address: "sss", addressInstructions: "sss")
        request.customerAddress = address
        request.customerReference = ""
        request.language = .english
        request.mobileCountryCode = MFMobileCountryCodeISO.kuwait.rawValue
        request.displayCurrencyIso = .kuwait_KWD
        return request
    }
}
