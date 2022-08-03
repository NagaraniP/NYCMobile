//
//  NetworkRequestObject.swift
//  NYCMobile
//
//  Created by raniraja on 8/3/22.
//

import Foundation
import Combine

class NetworkManager {
    
    static let shared = NetworkManager()
    var anyCancelable = Set<AnyCancellable>()
    
    func getResults<T: Codable>(_ model: T.Type , urlStr: String) -> Future<T, Error> {
        let url = URL(string: urlStr)!
        let decoder = JSONDecoder()
        
        return Future {[weak self] promise in
            guard let self = self else {return}
            URLSession.shared.dataTaskPublisher(for: url)
                .retry(1)
                .mapError {$0}
                .tryMap { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return element.data
                }
                .decode(type: model.self , decoder: decoder)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:  print("Publisher is finished")
                    }
                } receiveValue: { data in
                    promise(.success(data))
                }
                .store(in: &self.anyCancelable)
        }
    }
}
protocol ApiManagerProtocol {
    func fetch<T: Codable>(_ model: T.Type, withURL: String
                           , receiveCompletion: @escaping((Subscribers.Completion<Error>)-> Void) ,
                           receiveValue: @escaping(T)-> Void , subscripation: inout Set<AnyCancellable>)
}

class APiManager: ApiManagerProtocol {
    
    
    
    func fetch<T: Codable>(_ model: T.Type, withURL: String
                           ,receiveCompletion: @escaping((Subscribers.Completion<Error>)-> Void) ,
                           receiveValue: @escaping(T)-> Void ,
                           subscripation: inout Set<AnyCancellable>){
        
        guard !withURL.isEmpty else{return}
        NetworkManager.shared.getResults(model, urlStr: withURL)
            .receive(on: DispatchQueue.main)
            .map {$0}
            .sink(receiveCompletion: receiveCompletion, receiveValue: { T in
                receiveValue(T)
            })
            .store(in: &subscripation)
            
    }
    
}
