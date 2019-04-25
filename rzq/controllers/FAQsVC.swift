//
//  FAQsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import FittedSheets

class FAQsVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var items = [FAQsDatum]()
    
    @IBOutlet weak var btnMenu: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 56.0
        
        ApiService.getAllFAQs { (response) in
            self.items.append(contentsOf: response.faQsData ?? [FAQsDatum]())
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
        }
        // Do any additional setup after loading the view.
        
          self.btnMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sheetContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionAnswerVC") as! QuestionAnswerVC
      
        sheetContent.faq = self.items[indexPath.row]
        let sheet = SheetViewController(controller: sheetContent, sizes: [.halfScreen, .fullScreen])
        sheet.willDismiss = { _ in
            // This is called just before the sheet is dismissed
        }
        sheet.didDismiss = { _ in
            // This is called after the sheet is dismissed
        }
        
        self.present(sheet, animated: false, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : QuestionCell = tableView.dequeueReusableCell(withIdentifier: "questioncell", for: indexPath) as! QuestionCell
        
        cell.lblQuestion.text = self.items[indexPath.row].question ?? ""
        
        return cell
    }
    
   
}
