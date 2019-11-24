//
//  ProviderRatingsVC.swift
//  rzq
//
//  Created by Zaid Khaled on 11/1/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit

class ProviderRatingsVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var providerId : String?
    
    var items = [RatingDatum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 88.0
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showLoading()
        ApiService.getUserRatings(Authorization: self.loadUser().data?.accessToken ?? "", userId: self.providerId ?? "") { (response) in
            self.hideLoading()
            self.items.append(contentsOf: response.ratingsData?.ratingData ?? [RatingDatum]())
            self.tableView.reloadData()
            
            if (self.items.count == 0) {
                self.tableView.setEmptyView(title: "no_ratings".localized, message: "no_ratings_desc".localized, image: "bg_no_data")
            }else {
                self.tableView.restore()
            }
        }
    }
    
    
    //tableview delegate
    //     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 88.0
    //     }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProviderRatingCell = tableView.dequeueReusableCell(withIdentifier: "ProviderRatingCell", for: indexPath as IndexPath) as! ProviderRatingCell
        
        let item = self.items[indexPath.row]
        
        cell.lblUserName.text = item.fullName ?? ""
        cell.lblComment.text = item.comment ?? ""
        let doubleRating = Double(item.rate ?? 0)
        cell.ratingView.rating = doubleRating
        cell.ratingView.isUserInteractionEnabled = false
        
        return cell
    }
    
    
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
