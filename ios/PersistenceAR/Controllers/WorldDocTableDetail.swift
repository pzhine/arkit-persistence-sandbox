//
//  WorldDocTableDetail.swift
//  PersistenceAR
//
//  Created by Paul on 11/22/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import Foundation
import UIKit

class WorldDocTableDetail: UIViewController {
    @IBOutlet var nameField: UITextField!
    @IBOutlet var uploadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var downloadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet var loadButton: UIBarButtonItem!
    @IBOutlet var versionIdLabel: UILabel!
    @IBOutlet var lastModifiedLabel: UILabel!
    @IBOutlet var worldIdLabel: UILabel!
    
    private var hud :MBProgressHUD!
    
    var detailItem: WorldDoc? {
        didSet {
            if isViewLoaded {
                configureView()
            }
        }
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      configureView()
    }
    
    func configureView() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy HH:mm:ss"
        
        guard let detailItem = detailItem else {
            fatalError("detailItem not initialized")
        }
        
        guard let data = detailItem.data else {
            fatalError("data not initialized")
        }
        
        if (data.needsUpdate) {
            loadButton.isEnabled = false
            uploadButton.isEnabled = false
        }
        
        worldIdLabel.text = data.worldId
        nameField.text = data.name
        versionIdLabel.text = data.versionId
        
        guard let lastModified = data.lastModified else {
            lastModifiedLabel.text = "unknown"
            return
        }
        lastModifiedLabel.text = dateFormatter.string(from: lastModified)

    }
    
    func enableActions(_ enabled: Bool) {
        nameField.isEnabled = enabled
        uploadButton.isEnabled = enabled
        downloadButton.isEnabled = enabled
        navigationItem.hidesBackButton = !enabled
        loadButton.isEnabled = enabled
    }
    
    @IBAction func nameFieldChanged(_ sender: UITextField) {
        detailItem?.data?.name = sender.text!
        detailItem?.saveData()
        self.title = sender.text!
    }
    
    @IBAction func loadButtonPressed(_ sender: UIBarButtonItem) {
        let vc = presentingViewController as! ViewController
        vc.worldDoc = detailItem!
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonPressed(_ sender: UIButton) {
        uploadActivityIndicator.startAnimating()
        enableActions(false)
        detailItem!.upload() { (result) in
            guard let error = result.error else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Upload Complete", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.uploadActivityIndicator.stopAnimating()
                    self.enableActions(true)
                }
                return
            }
            DispatchQueue.main.async {
                print(error)
                let alert = UIAlertController(title: "Upload Error", message: error.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.uploadActivityIndicator.stopAnimating()
                self.enableActions(true)
            }
        }
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        downloadActivityIndicator.startAnimating()
        enableActions(false)
    }
    
}

extension WorldDocTableDetail: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
