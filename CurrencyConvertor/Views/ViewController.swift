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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dropDownClicked))
        tapGesture.numberOfTapsRequired = 1
        vwDropDown.addGestureRecognizer(tapGesture)
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
        let calculatedRate = (exchangeObject.rate / selectedExchangeRate)
        cell.lblExchangeRateText.text = "\(calculatedRate) \(exchangeObject.currencyName)"
        return cell
    }
}

