//
//  NYCSATDetailsViewModelObject.swift
//  NYCMobile
//
//  Created by raniraja on 8/3/22.
//

import UIKit
import Combine

private struct LocalConstants {
    static let serverReachability = "Unable to reach Server"
    static let tryAgain = "Please tryagain later"
    static let connectionLost = "Connetion Lost"
}
class NYCSATDetailsViewModelObject: NSObject {
    private var subscribation = Set<AnyCancellable>()
    //typealias completionBlock = () -> Void
    typealias completionBlock = (Bool, String?) -> Void
    /*** Creating instance to call network api ***/
    private var apiManager: ApiManagerProtocol
    /** Creating instance to store SAT data **/
    @Published var schoolSATDaataObject: SchoolSATResults?
    
    init(apiManager: ApiManagerProtocol = APiManager()){
        self.apiManager = apiManager
    }
    
    func getSchoolDataFromNetworkAPI(urStr: String, completionBlock: @escaping completionBlock) {
        /** After calling network based on responce will parse or update UI **/
        apiManager.fetch([SchoolSATResults].self, withURL: urStr, receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                completionBlock(false, (error.localizedDescription))
            case .finished :
                completionBlock(true, nil)
            }
        }, receiveValue: { schoolDetails in
            if schoolDetails.count > 0 {
                self.schoolSATDaataObject = schoolDetails[0]
            }
        }, subscripation: &subscribation)
    }
    
    func getAlertInfo(errorDescription: String) -> (String, String) {
        switch errorDescription {
        case errorInfo.internetConnection.rawValue:
            return (LocalConstants.connectionLost, LocalConstants.tryAgain)
        default :
            return (LocalConstants.serverReachability, LocalConstants.tryAgain)
        }
    }
    /** Getting SAT match avg score ***/
    func getMathScore() -> String {
        return (schoolSATDaataObject?.mathAvgScore) ?? scoreNotAvaible
    }
    
    /** Getting SAT Avg reading score ***/
    func getReadingScore() -> String {
        return schoolSATDaataObject?.readAvgScore ?? scoreNotAvaible
    }
    
    /** Getting writing avg score ***/
    func getWritingScore() -> String {
        return schoolSATDaataObject?.writingAvgScore ?? scoreNotAvaible
    }
    
    /*** Formatting email to clickable link ***/
    func getSchoolClikable(text: String?) -> NSAttributedString {
        if  text != nil {
            let range = (text! as NSString).range(of: text!, options: .caseInsensitive)
            let attributeStr: NSMutableAttributedString = NSMutableAttributedString(string: text!)
            attributeStr.addAttribute(.link, value: text!, range: range )
            return attributeStr
        }
        return NSAttributedString(string: "Info Not Available")
    }
    
    /***  Formatting mail clickable **/
    func getMailFormat(text: String?) -> String {
        return text ?? ""
    }
    
    /*** Formatting phone number ***/
    func call(phoneNumber: String?) -> URL? {
        let cleanPhoneNumber = phoneNumber?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        let urlString: String = "tel://\(cleanPhoneNumber ?? "")"
        if let phoneCallURL = URL(string: urlString) {
            return phoneCallURL
        }
        return nil
    }
}
