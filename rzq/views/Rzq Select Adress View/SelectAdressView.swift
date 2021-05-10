//
//  SelectAdressView.swift
//  rzq
//
//  Created by Said Elmansour on 2021-05-03.
//  Copyright © 2021 technzone. All rights reserved.
//

import UIKit

protocol SelectAdressViewDelegate: class {
    func onClose()
    func selectedAdress(userAdressData: userAdressData?)
    func onAddNewAdress()
}

class SelectAdressView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Views
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var adressContainerView: UIView!
    @IBOutlet weak var closeButtonContainer: UIView!
    @IBOutlet weak var addNewAdressButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var selectAdressLabel: UILabel!
    
    // MARK: - Properties
    
    weak var delegate: SelectAdressViewDelegate?
    var userAdressData: [userAdressData]?
    
    static func instantiate() -> UIView {
        UINib.loadSingleView(String(describing: self), owner: nil)
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupLocalize()
        setupTableView()
        
        ApiService.getAddress(Authorization: DataManager.loadUser().data?.accessToken ?? "") { (reesult) in
            self.userAdressData = reesult.userAdressData
            DispatchQueue.main.async {
                
                let constantHeight = self.userAdressData?.count ?? 1 > 3 ? (3 * 105) : (self.userAdressData?.count ?? 1) * 105
                self.tableViewHeightConstraint.constant = CGFloat(constantHeight)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Local Halpers
    
    private func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Remove the extra empty Cells
        tableView.tableFooterView = UIView()
        
        // Register the Cells
        tableView.registerCell(identifier: AdressCell.identifier)
    }
    
    private func setupUI() {
        self.adressContainerView.layer.cornerRadius = 20
        self.closeButtonContainer.layer.cornerRadius = 15
        self.tableViewHeightConstraint.constant = 1 * 105
    }
    
    private func setupLocalize() {
        self.selectAdressLabel.text = "addAdress.title".localized
        self.orLabel.text = "address.or.title".localized
        addNewAdressButton.setTitle( "address.button.title".localized, for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func onCloseButton(_ sender: Any) {
        self.delegate?.onClose()
        self.removeFromSuperview()
    }
    
    @IBAction func onAddNewAdress(_ sender: Any) {
        self.delegate?.onAddNewAdress()
        self.removeFromSuperview()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAdressData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AdressCell.identifier) as? AdressCell else { return UITableViewCell() }
        cell.checkMarkView.style = .grayedOut

        cell.configure(userAdressData: self.userAdressData?[indexPath.row])
        cell.checkMarkView.setNeedsDisplay()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? AdressCell else { return }
        
        cell.checkMarkView.checked = !cell.checkMarkView.checked
        self.delegate?.selectedAdress(userAdressData: self.userAdressData?[indexPath.row])
        self.removeFromSuperview()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105.0
    }
}
