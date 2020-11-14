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
    private let exchangeRateFileName = "ExchangeRates"
    private let quotesKey = "quotes"
    
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
        storeInitialExchangeRateDataIfNeeded()
        callApiToFetchExchangeRates()
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
                case .success(let data):
                    self?.storeDownloadedExchangeRates(data: data)
                    self?.exchangeRates = self?.getExchangeratesFromResponse(data: data) ?? []
                case .failure(_):
                    self?.exchangeRates = []
                }
            }
        }
    }
    
    func getLocallyStoredExchangeRate() {
        do {
            let filePath = getExchangeRateFilePath()
            if FileManager.default.fileExists(atPath: filePath) {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                exchangeRates = getExchangeratesFromResponse(data: data) ?? []
            }
        } catch {}
    }
    
    func storeInitialExchangeRateDataIfNeeded() {
        do {
            if let filePath = Bundle.main.path(forResource: exchangeRateFileName, ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                guard let cacheDirectory = pathForCacheDirectory() else { return }
                let path = cacheDirectory + "/\(exchangeRateFileName).json"
                if !FileManager.default.fileExists(atPath: path) {
                    let _ = FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
                }
            }
        } catch {}
    }
    
    private func storeDownloadedExchangeRates(data : Data) {
        do {
            let filePath = getExchangeRateFilePath()
            try FileManager.default.removeItem(atPath: filePath)
            FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
        } catch {}
    }
    
    private func getExchangeratesFromResponse(data: Data) -> [ExchangeRate]? {
        do {
            guard let responseDict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any],
                let currencies = responseDict[quotesKey] as? [String : Double] else { return nil }
            var list: [ExchangeRate] = []
            for (key, value) in currencies {
                let startIndex = key.index(key.startIndex, offsetBy: 3)
                let endIndex = key.index(startIndex, offsetBy: 3)
                let currencyName = String(key[startIndex..<endIndex])
                list.append(ExchangeRate(currencyName: currencyName, rate: value))
            }
            return list
        } catch {
            return nil
        }
    }
    
    private func getExchangeRateFilePath() -> String {
        guard let cacheDirectory = pathForCacheDirectory() else { return "" }
        return (cacheDirectory + "\(exchangeRateFileName).json)")
    }
    
    private func pathForCacheDirectory() -> String? {
        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    }
}
