//
//  UpdateCategoryNameSheet.swift
//  rzq
//
//  Created by Zaid Khaled on 10/27/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol CategoryNameSheetDelegate {
    func onSubmit(cat: ShopOwnerDatum, englishName: String, arabicName: String)
}
class UpdateCategoryNameSheet: BaseVC {

    @IBOutlet weak var fieldEnglishName: MyUITextField!
    @IBOutlet weak var fieldArabicName: MyUITextField!
    
    
    var delegate : CategoryNameSheetDelegate?
    
    var cat : ShopOwnerDatum?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateAction(_ sender: Any) {
        if (self.fieldEnglishName.text?.count ?? 0 > 0 && self.fieldArabicName.text?.count ?? 0 > 0 ) {
            self.delegate?.onSubmit(cat: self.cat!, englishName: self.fieldEnglishName.text ?? "", arabicName: self.fieldArabicName.text ?? "")
        }else {
            self.showBanner(title: "alert".localized, message: "enter_category_name".localized, style: UIColor.INFO)
        }
    }
}
