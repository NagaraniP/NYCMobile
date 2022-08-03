//
//  NYCNetworkAPI.swift
//  NYCMobile
//
//  Created by raniraja on 8/3/22.
//

import Foundation

enum Constants {
    static  let kGetNYCList = "https://data.cityofnewyork.us/resource/s3k6-pzi2.json"
    static let kGetNYCSATDetails = "https://data.cityofnewyork.us/resource/f9bf-2cp4.json"
}
enum APIClientError: Error {
    case unknown(internalError: Error?)
    case decodingError
}
