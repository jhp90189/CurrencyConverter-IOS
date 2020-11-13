//
//  ViewController.swift
//  CurrencyConvertor
//
//  Created by Apple on 12/11/20.
//  Copyright © 2020 Jainesh Patel. All rights reserved.
//

import UIKit

class CurrencyViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var vwDropDown: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblSelectedCurrency: UILabel!
    
    private var viewModel = CurrencyViewModel()
    private var selectedCurrency = Currency(shortName: "USD", fullName: "United States Dollar")
    private var selectedExchangeRate: Double = 1.0
    private var exchangeRates: [ExchangeRate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.callApiToFetchExchangeRates()
        viewModel.bindExchangeRates = { [weak self] rates in
            self?.exchangeRates = rates
            self?.collectionView.reloadData()
        }
    }
    
    private func setupView() {
        self.title = "CurrencyConvertor"
        lblSelectedCurrency.layer.borderWidth = 2.0
        lblSelectedCurrency.layer.borderColor = UIColor.black.cgColor
        updateCurrencyUI()
        // Tap gesture for drop down click
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dropDownClicked))
        tapGesture.numberOfTapsRequired = 1
        vwDropDown.addGestureRecognizer(tapGesture)
        
        //tap gesture to hide keyboard
        let tapForKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapForKeyboard)
    }
    
    @objc func dismissKeyboard() {
        txtAmount.resignFirstResponder()
    }

    @objc func dropDownClicked() {
        self.performSegue(withIdentifier: "tocurrencylistview", sender: nil)
    }
    
    private func updateCurrencyUI() {
        lblSelectedCurrency.text = selectedCurrency.shortName
        let exchangeObject = exchangeRates.first { [weak self] rate -> Bool in
            return (rate.currencyName == self?.selectedCurrency.shortName)
        }
        selectedExchangeRate = exchangeObject?.rate ?? 1.0
        collectionView.reloadData()
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

extension CurrencyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exchangeRates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exchangecell", for: indexPath) as! ExchangeRateCell
        let exchangeObject = exchangeRates[indexPath.row]
        let amount = Double(txtAmount.text ?? "1") ?? 1.0
        let calculatedRate = String(format: "%.2f", amount * (exchangeObject.rate / selectedExchangeRate))
        cell.lblExchangeRateText.text = "\(calculatedRate) \(exchangeObject.currencyName)"
        cell.contentView.layer.borderWidth = 2
        cell.contentView.layer.borderColor = UIColor.darkGray.cgColor
        return cell
    }
}

extension CurrencyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if Int(textField.text ?? "0") ?? 0 <= 0 { textField.text = "1.00" }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        collectionView.reloadData()
    }
}

