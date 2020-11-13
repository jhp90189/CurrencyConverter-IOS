//
//  CurrencyViewModel.swift
//  CurrencyConvertor
//
//  Created by Apple on 13/11/20.
//  Copyright © 2020 Jainesh Patel. All rights reserved.
//

import Foundation

class CurrencyViewModel: NSObject {
    
    private let apiService = CurrencyServices()
    
    private(set) var currencyList: [Currency] = [] {
        didSet {
            self.bindCurrencyList(currencyList)
        }
    }
    
    private(set) var exchangeRates: [ExchangeRate] = [] {
        didSet {
            self.bindExchangeRates(exchangeRates)
        }
    }
    
    var bindCurrencyList : (([Currency]) -> ()) = { _ in }
    var bindExchangeRates : (([ExchangeRate]) -> ()) = { _ in }

    
    override init() {
        super.init()
    }
    
    func callApiToFetchCurrencyList() {
        apiService.fetchCurrencyList { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.currencyList = response
                case .failure(_):
                    self?.currencyList = []
                }
            }
        }
    }
    
    func callApiToFetchExchangeRates() {
        apiService.fetchExchangeRates{ [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.exchangeRates = response
                case .failure(_):
                    self?.exchangeRates = []
                }
            }
        }
    }
}
