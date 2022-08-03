//
//  NYCSchoolsSATDetailsViewController.swift
//  NYCMobile
//
//  Created by raniraja on 8/3/22.
//

import UIKit
import MessageUI
import QuartzCore

private struct LocalConstants {
    static let EmailNotSent = "Could not sent email"
    static let DeviceEmailSupport = "Check if your device have email support!"
    static let DevicePhoneCall =  "Device does not support phone calls."
    static let AlertITitle = "Alert"
    static let alertOk = "OK"
    static let navTitle = "School Info"

}
@IBDesignable class NYCSchoolsSATDetailsViewController: NYCRootViewController, MFMailComposeViewControllerDelegate {
    /** As i need to access in previous VC so not declaring as private ***/
    var schoolDetailsObject: SchoolInfo!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var writingScoreLabel: UILabel!
    @IBOutlet weak var readingScoreLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mathScoreLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    /*** Creating instance for calling network API ***/
    private var schoolDetailsViewModelObject = NYCSATDetailsViewModelObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Back"
        updateSchoolInfo()
        let schoolDetails = "\(Constants.kGetNYCSATDetails)\("/?dbn=")\(schoolDetailsObject.dbn!)"
        schoolDetailsViewModelObject.getSchoolDataFromNetworkAPI(urStr: schoolDetails) { [weak self]success, errorDescription in
            if success {
                self?.updateUI()
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.stopAnimating()
                    if let errorDes = errorDescription {
                    let alertInfo: (String, String) = self.schoolDetailsViewModelObject.getAlertInfo(errorDescription: errorDes)
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
    }
    
    /*** Update school data ***/
    func updateSchoolInfo() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(contactlabelClicked))
        contactLabel.addGestureRecognizer(gesture)
        let emailgesture = UITapGestureRecognizer(target: self, action: #selector(emailClickable))
        emailLabel.addGestureRecognizer(emailgesture)
    }
    
    /** Mail compose ***/
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Sent")
        case MFMailComposeResult.failed.rawValue:
            print("Error:)")
        default:
            break
        }
        controller.dismiss(animated: true)
    }
    
    /*** Email click action ***/
    @objc func emailClickable() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([schoolDetailsViewModelObject.getMailFormat(text: schoolDetailsObject?.schoolEmail)])
            mail.setMessageBody("<p>Hello!</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            showError()
            // show failure alert
        }
    }
    
    /** Show error email device support***/
    func showError() {
        let alertMessage = UIAlertController(title: LocalConstants.EmailNotSent, message: LocalConstants.DeviceEmailSupport, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: LocalConstants.alertOk, style: UIAlertAction.Style.default, handler: nil)
        alertMessage.addAction(action)
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    /** conatact action **/
    @objc func contactlabelClicked() {
        guard UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone else {
            let alertMessage = UIAlertController(title: LocalConstants.AlertITitle, message: LocalConstants.DevicePhoneCall, preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: LocalConstants.alertOk, style: UIAlertAction.Style.default, handler: nil)
            alertMessage.addAction(action)
            self.present(alertMessage, animated: true, completion: nil)
            return
        }
        UIApplication.shared.open(schoolDetailsViewModelObject.call(phoneNumber: schoolDetailsObject?.schoolContact)!)
    }
    
    /** Updating UI SAT and School Info ***/
    func updateUI() {
        infoView.layer.borderWidth = 1
        detailsView.layer.borderWidth = 1
        infoView.layer.borderColor = UIColor.white.cgColor
        detailsView.layer.borderColor = UIColor.white.cgColor
        infoView.layer.cornerRadius = 10
        detailsView.layer.cornerRadius = 10
        self.nameLabel.text = schoolDetailsObject?.schoolName  ?? ""
        self.contactLabel.attributedText = schoolDetailsViewModelObject.getSchoolClikable(text: schoolDetailsObject?.schoolContact)
        self.emailLabel.attributedText = schoolDetailsViewModelObject.getSchoolClikable(text: schoolDetailsObject?.schoolEmail)
        self.readingScoreLabel.textColor = UIColor.black
        self.mathScoreLabel.text = schoolDetailsViewModelObject.getMathScore()
        self.readingScoreLabel.text = schoolDetailsViewModelObject.getReadingScore()
        self.writingScoreLabel.text = schoolDetailsViewModelObject.getWritingScore()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

