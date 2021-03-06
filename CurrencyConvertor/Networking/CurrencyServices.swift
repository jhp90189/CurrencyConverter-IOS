//
//  EmployeeAPIServices.swift
//  EmployeeServices
//
//  Created by Apple on 28/09/20.
//  Copyright © 2020 Rajesh Sammita. All rights reserved.
//

import Foundation

//EmployeeAPIServ1ces c ass
// conf1·gure endpoint to make service calls
class CurrencyServices {
    
    private let apiClient = APIClient()
    private let baseURL = "http://api.currencylayer.com"
    private let apiKey = "access_key=c4ddd0548cf544a5360392c42fa49bb8"
    private let currencyListLocalFileName = "CurrencyList"
    private let currenciesKey = "currencies"
    private var getListOfCurrencyURL : String {
        return baseURL + "/list?" + apiKey
    }
    private var getExchangeRatesURL : String {
        return baseURL + "/live?" + apiKey
    }
    
    //API call to fetch list of employees
    func fetchCurrencyList(completion: @escaping ((Result<[Currency]>) -> Void)) {
        guard let listURL = URL(string: getListOfCurrencyURL) else { return }
        let resourse = Resource(url: listURL)
        apiClient.load(resourse) { [weak self] result in
            switch result {
            case .success(let data):
                let items = self?.getCurrenciesFromResponse(data: data) ?? []
                completion(.success(items))
            case .failure(let error):
                if let localList = self?.getStubbedCurrencyList() {
                    completion(.success(localList))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func getStubbedCurrencyList() -> [Currency]? {
        do {
            if let filePath = Bundle.main.path(forResource: currencyListLocalFileName, ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                return getCurrenciesFromResponse(data: data) ?? []
            }
            return nil
        } catch { return nil }
    }
    
    private func getCurrenciesFromResponse(data: Data) -> [Currency]? {
        do {
            guard let responseDict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any],
                let currencies = responseDict[currenciesKey] as? [String : String] else { return nil }
            var list: [Currency] = []
            for (key, value) in currencies {
                list.append(Currency(shortName: key, fullName: value))
            }
            return list
        } catch {
            return nil
        }
    }
    
    func fetchExchangeRates(completion: @escaping ((Result<Data>) -> Void)) {
        guard let listURL = URL(string: getExchangeRatesURL) else { return }
        let resourse = Resource(url: listURL)
        apiClient.load(resourse) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
