//
//  ShopTypesFilterVC.swift
//  rzq
//
//  Created by Zaid najjar on 5/15/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol TypeListDelegate {
    func onClick(type : TypeClass)
}

class ShopTypesFilterVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchField: MyUITextField!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    var latitude : Double?
    var longitude : Double?
    
    var items = [TypeClass]()
    
    var delegate : TypeListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.reloadTypes()
        
        if (self.isArabic()) {
            self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }

    
        self.searchField.delegate = self
        
        
    }
    
    func reloadTypes() {
        ApiService.getAllTypes { (response) in
            if (response.errorCode == 0) {
                self.items.removeAll()
                self.items.append(contentsOf: response.data ?? [TypeClass]())
                self.tableView.reloadData()
            }
        }
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
        
        if (item.image?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(item.image ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }
        
        cell.lblName.text = item.name ?? ""
        
        return cell
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
                
                let arr = self.items.filter {
                    $0.name?.lowercased().range(of: newString.lowercased as String) != nil
                }
                self.items.removeAll()
                self.items.append(contentsOf: arr)
                self.tableView.reloadData()
            }
            if (newString.length == 0) {
                self.reloadTypes()
            }
            return newString.length <= maxLength
        }
        
        return false
    }
    
}
