//
//  FAQsVC.swift
//  rzq
//
//  Created by Zaid najjar on 4/16/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import FittedSheets

class FAQsVC: BaseVC, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var items = [FAQsDatum]()
    
    @IBOutlet weak var ivHandle: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 56.0
        
        if (self.isArabic()) {
              self.ivHandle.image = UIImage(named: "ic_back_arabic")
        }
        
        ApiService.getAllFAQs { (response) in
            self.items.append(contentsOf: response.faQsData ?? [FAQsDatum]())
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
        }
      
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let sheetContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionAnswerVC") as! QuestionAnswerVC
//
//        sheetContent.faq = self.items[indexPath.row]
//        let sheet = SheetViewController(controller: sheetContent, sizes: [.halfScreen, .fullScreen])
//        sheet.willDismiss = { _ in
//            // This is called just before the sheet is dismissed
//        }
//        sheet.didDismiss = { _ in
//            // This is called after the sheet is dismissed
//        }
//
//        self.present(sheet, animated: false, completion: nil)
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnswersVC") as? AnswersVC
        {
            vc.item = self.items[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : QuestionCell = tableView.dequeueReusableCell(withIdentifier: "questioncell", for: indexPath) as! QuestionCell
        
        cell.lblQuestion.text = self.items[indexPath.row].question ?? ""
        
        return cell
    }
    
    @IBAction func blackAction(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
    }
    
   
}
