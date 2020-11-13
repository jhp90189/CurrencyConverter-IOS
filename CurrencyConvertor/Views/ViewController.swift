//
//  ViewController.swift
//  CurrencyConvertor
//
//  Created by Apple on 12/11/20.
//  Copyright © 2020 Jainesh Patel. All rights reserved.
//

import UIKit

class CurrencyViewController: UIViewController {
    
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var vwDropDown: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblSelectedCurrency: UILabel!
    
    private var viewModel = CurrencyViewModel()
    private var selectedCurrency : Currency?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }
    
    private func setupView() {
        self.title = "CurrencyConvertor"
        vwDropDown.layer.borderWidth = 2.0
        vwDropDown.layer.borderColor = UIColor.black.cgColor
        vwDropDown.layer.cornerRadius = 3.0

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dropDownClicked))
        tapGesture.numberOfTapsRequired = 1
        vwDropDown.addGestureRecognizer(tapGesture)
    }

    @objc func dropDownClicked() {
        self.performSegue(withIdentifier: "tocurrencylistview", sender: nil)
    }
    
    private func updateCurrencyUI() {
        lblSelectedCurrency.text = selectedCurrency?.shortName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tocurrencylistview" {
            let listViewController = segue.destination as? CurrencyListViewController
            listViewController?.viewModel = viewModel
            listViewController?.selectedCurrency = selectedCurrency
            listViewController?.currencySelectionCallBack = { [weak self] currency in
                self?.selectedCurrency = currency
                self?.updateCurrencyUI()
            }
        }
    }
}

