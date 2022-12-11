//
//  ViewController.swift
//  App Update Checker
//
//  Created by Neelesh on 11/12/22.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check the README File first
        checkIfUpdateAvailable()
    }
    
    // MARK: - Functions
    
    private func checkIfUpdateAvailable() {
        let bundle = Bundle.main.infoDictionary!
        let bundleId = bundle["CFBundleIdentifier"] as! String
        let currentVersion = bundle["CFBundleShortVersionString"] as! String
        
        let URL = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)")!
        URLSession.shared.dataTask(with: URL) { [weak self] (data, response, error) in
            if let error = error {
                print("Debugger ERROR", error.localizedDescription)
            }
            else {
                let JSONResponse = try? JSONDecoder().decode(AppUpdateResponseModel.self, from: data!)
                if let JSONResponse = JSONResponse, let results = JSONResponse.results, results.count>0 {
                    if results[0].version == currentVersion {
                        print("Debugger your app is upto date")
                    }
                    else {
                        DispatchQueue.main.async {
                            self?.showUpdateAlert(appStoreURL: results[0].trackViewUrl)
                        }
                    }
                }
                else {
                    print("Debugger No app found")
                }
            }
        }.resume()
    }
    
    private func showUpdateAlert(appStoreURL: String) {
        let alertController = UIAlertController(title: StringConstants.appUpdateTitle, message: StringConstants.appUpdateDescription, preferredStyle: .alert)
        
        let updateAction = UIAlertAction(title: StringConstants.update, style: .cancel, handler: { _ in
            UIApplication.shared.open(URL(string: appStoreURL)!, options: [:], completionHandler: nil)
        })
        alertController.addAction(updateAction)
        
        let cancelAction = UIAlertAction(title: StringConstants.cancel, style: .default)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func checkUpdateAction(_ sender: UIButton) {
        checkIfUpdateAvailable()
    }
}

// MARK: - App Update Response Model

struct AppUpdateResponseModel: Decodable {
    var results: [AppInfoModel]?
}

struct AppInfoModel: Decodable {
    var version, trackViewUrl: String
}
