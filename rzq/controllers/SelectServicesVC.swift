//
//  SelectServicesVC.swift
//  rzq
//
//  Created by Zaid najjar on 5/25/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

protocol SelectServicesDelegate {
    func onSubmit(services : [Int])
}
class SelectServicesVC: BaseVC, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var ivHandle: UIImageView!
    
     var items = [ServiceData]()
    
    var delegate : SelectServicesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        ApiService.getAllServices(name: "") { (response) in
            self.items.removeAll()
            self.items.append(contentsOf: response.data ?? [ServiceData]())
            self.tableView.reloadData()
        }

        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SelectServiceCell = tableView.dequeueReusableCell(withIdentifier: "selectservicecell", for: indexPath) as! SelectServiceCell
        
        let item = self.items[indexPath.row]
        cell.lblName.text = item.name ?? ""
        
        if (item.image?.count ?? 0 > 0) {
            let url = URL(string: "\(Constants.IMAGE_URL)\(item.image ?? "")")
            cell.ivLogo.kf.setImage(with: url)
        }
        
        cell.onSelect = {
            item.isChecked = cell.isChecked
            self.tableView.reloadData()
        }
        
        return cell
    }
    
    @IBAction func submitAction(_ sender: Any) {
        var selectedServices = [Int]()
        for item in self.items {
            if (item.isChecked ?? false) {
                selectedServices.append(item.id ?? 0)
            }
        }
        self.delegate?.onSubmit(services: selectedServices)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
