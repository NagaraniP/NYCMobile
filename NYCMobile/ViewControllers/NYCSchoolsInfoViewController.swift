//
//  NYCSchoolsInfoViewController.swift
//  NYCMobile
//
//  Created by raniraja on 8/3/22.
//

import UIKit

private struct LocalConstants {
    static let customTableCell = "CustomTableViewCell"
    static let cellReUse = "cellReUse"
    static let alertOk = "OK"
    static let navTitleName = "NYCSchools"
}

class NYCSchoolsInfoViewController: NYCRootViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var schoolInfoObject: SchoolInfo!
    private var viewModelObj = NYCSchoolsViewModelObject()
    override func viewDidLoad() {
        super.viewDidLoad()
       /*** Registering custom cell xib ***/
        tableView.register(UINib(nibName: LocalConstants.customTableCell, bundle: nil), forCellReuseIdentifier: LocalConstants.cellReUse)
        /*** search delagte to self to trigger search callbacks ***/
        searchBar.delegate = self
        self.startAnimating("Fetching...")
        /** Hiding the table untill we recieve success responce ***/
        tableView.isHidden = true
        viewModelObj.getSchoolDataFromNetworkAPI(urStr: Constants.kGetNYCList ) { (success, errorDescription) in
            if success {
                DispatchQueue.main.async { [weak self] in
                    if let selfObj = self {
                        selfObj.tableView.isHidden = false
                        selfObj.stopAnimating()
                        selfObj.tableView.reloadData()
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.stopAnimating()
                    if let errorDes = errorDescription {
                    let alertInfo: (String, String) = self.viewModelObj.getAlertInfo(errorDescription: errorDes)
                    let alert = UIAlertController(title: alertInfo.0, message: alertInfo.1, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: LocalConstants.alertOk, style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = LocalConstants.navTitleName
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vcObj: NYCSchoolsSATDetailsViewController = segue.destination as? NYCSchoolsSATDetailsViewController {
            vcObj.schoolDetailsObject = schoolInfoObject
        }
    }
}

/** Extension for tableview callback ***/
extension NYCSchoolsInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModelObj.numberOfSchoolsInRow()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellObj = tableView.dequeueReusableCell(withIdentifier: LocalConstants.cellReUse, for: indexPath) as! CustomTableViewCell
        cellObj.nameLabel.text = viewModelObj.schoolNameAtIndexPath(indexpath: indexPath)
        return cellObj
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        schoolInfoObject = viewModelObj.didSelectSchoolAtIndexPath(indexPath: indexPath)
        self.performSegue(withIdentifier: kNYCSchoolStoryBoardSegue, sender: nil)
    }
}

/*** Extension for search bar callbacks ***/
extension NYCSchoolsInfoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModelObj.searchText(stext: searchText)
        self.tableView.reloadData()
    }
}
