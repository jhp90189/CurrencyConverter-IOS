//
//  CurrencyListViewController.swift
//  CurrencyConvertor
//
//  Created by Apple on 13/11/20.
//  Copyright © 2020 Jainesh Patel. All rights reserved.
//

import UIKit

class CurrencyListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var currencyList: [Currency] = []
    var selectedCurrency : Currency?
    var viewModel: CurrencyViewModel?
    var currencySelectionCallBack: ((Currency?) -> ()) = {_ in}
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        observeModel()
    }
    
    private func setupView() {
        self.title = "Select Currency"
    }
    
    private func observeModel() {
        viewModel?.callApiToFetchCurrencyList()
        viewModel?.bindCurrencyList = { [weak self] list in
            self?.currencyList = list
            self?.tableView.reloadData()
        }
    }
}

extension CurrencyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencycell", for: indexPath) as! CurrecyListCell
        
        cell.selectionStyle = .none
        let currency = currencyList[indexPath.row]
        cell.lblCurrency?.text = currency.shortName
        cell.accessoryType = (selectedCurrency?.shortName == currency.shortName) ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        selectedCurrency = currencyList[indexPath.row]
        currencySelectionCallBack(selectedCurrency)
        dismiss(animated: true, completion: nil)
    }
}