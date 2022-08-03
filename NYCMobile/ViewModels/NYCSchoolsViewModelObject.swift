//
//  NYCSchoolsViewModelObject.swift
//  NYCMobile
//
//  Created by raniraja on 8/3/22.
//

import UIKit
import Combine

private struct LocalConstants {
    static let serverReachability = "Unable to reach Server"
    static let connectionLost = "Connetion Lost"
    static let tryAgain = "Please tryagain later"
}
enum errorInfo: String {
    case internetConnection = "The Internet connection appears to be offline."
}
class NYCSchoolsViewModelObject: NSObject {
    
    private var subscribation = Set<AnyCancellable>()
    /** Creating instance of network class to call api ***/
    private var apiManager: ApiManagerProtocol
    /** Alias for existing type ***/
    typealias completionBlock = (Bool, String?) -> Void
    /** To append school info data ***/
    @Published var schoolInfoList = [SchoolInfo]()
    /** To append data to search filter array ***/
    private var filtered = [SchoolInfo]()
    private var searchText: String = ""
    
    init(apiManager: ApiManagerProtocol = APiManager()){
        self.apiManager = apiManager
    }
    
    func getSchoolDataFromNetworkAPI(urStr: String, completionBlock: @escaping completionBlock) {
        apiManager.fetch([SchoolInfo].self, withURL: urStr, receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                completionBlock(false, (error.localizedDescription))
            case .finished :
                completionBlock(true, nil)
            }
        }, receiveValue: { schoolInfo in
            self.schoolInfoList = schoolInfo
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
    
    /*** Table view number or rows based on array count / search filter count ***/
    func numberOfSchoolsInRow() -> Int {
        if searchText.count == 0 {
            return schoolInfoList.count
        } else {
            return filtered.count
        }
    }
    /*** school name to display in each row***/
    func schoolNameAtIndexPath(indexpath: IndexPath) -> String? {
        if filtered.count > 0 {
            return filtered[indexpath.row].schoolName!
        }
        if let name = schoolInfoList[indexpath.row].schoolName {
            return name
        }
        return nil
    }
    /*** Getting selected row dbn to pass to get SAT details ***/
    func didSelectSchoolAtIndexPath(indexPath: IndexPath) -> SchoolInfo {
        if filtered.count > 0 {
            return filtered[indexPath.row]
        }
        return schoolInfoList[indexPath.row]
    }
    
    /*** Based on search bar search test will filter ***/
    func searchText(stext: String) {
        filtered = schoolInfoList.filter({ (schoolObj) -> Bool in
            var searchObj: NSString = ""
            if let temp = schoolObj.schoolName as NSString? {
                searchObj = temp
            }
            searchText = stext
            let range = searchObj.range(of: stext, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
    }
}
