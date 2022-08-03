//
//  SchoolInfoModelObject.swift
//  NYCMobile
//
//  Created by raniraja on 8/3/22.
//

import Foundation

/*** School Info struct to store school info ***/
struct SchoolInfo: Decodable, Encodable {
   private enum CodingKeys: String, CodingKey {
        case schoolName = "school_name"
        case schoolEmail = "school_email"
        case schoolContact = "phone_number"
        case dbn
    }
    let schoolName: String?
    let schoolEmail: String?
    let schoolContact: String?
    let dbn: String?
}
