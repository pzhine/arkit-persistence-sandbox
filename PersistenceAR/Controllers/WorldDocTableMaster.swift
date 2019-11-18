//
//  WorldDocTableViewController.swift
//  WorldAsSupport
//
//  Created by Paul on 10/28/19.
//  Copyright © 2019 UPF. All rights reserved.
//

import Foundation
import UIKit

class WorldDocTableMaster: UITableViewController {
    var worldDocs: [WorldDoc] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Load Map"
        worldDocs = WorldDatabase.loadWorldDocs()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return worldDocs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorldDocCell", for: indexPath)
      
        let doc = worldDocs[indexPath.row]

        cell.textLabel!.text = doc.data?.name
//        cell.imageView!.image = doc.thumbImage
      
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let docToDelete = worldDocs.remove(at: indexPath.row)
            docToDelete.deleteDoc()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let worldDoc = worldDocs[indexPath.row]
        let vc = presentingViewController as! ViewController
        vc.worldDoc = worldDoc
        self.dismiss(animated: true, completion: nil)
    }
}
