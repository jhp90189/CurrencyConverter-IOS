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
    private var selectedCurrency = Currency(shortName: "USD", fullName: "United States Dollar")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }
    
    private func setupView() {
        self.title = "CurrencyConvertor"
        lblSelectedCurrency.layer.borderWidth = 2.0
        lblSelectedCurrency.layer.borderColor = UIColor.black.cgColor

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dropDownClicked))
        tapGesture.numberOfTapsRequired = 1
        vwDropDown.addGestureRecognizer(tapGesture)
    }

    @objc func dropDownClicked() {
        self.performSegue(withIdentifier: "tocurrencylistview", sender: nil)
    }
    
    private func updateCurrencyUI() {
        lblSelectedCurrency.text = selectedCurrency.shortName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tocurrencylistview" {
            let listViewController = segue.destination as? CurrencyListViewController
            listViewController?.viewModel = viewModel
            listViewController?.selectedCurrency = selectedCurrency
            listViewController?.currencySelectionCallBack = { [weak self] currency in
                self?.selectedCurrency = currency ?? Currency(shortName: "USD", fullName: "United States Dollar")
                self?.updateCurrencyUI()
            }
        }
    }
}

