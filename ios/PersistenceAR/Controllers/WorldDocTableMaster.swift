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
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let docToDelete = worldDocs.remove(at: indexPath.row)
            docToDelete.deleteDoc()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = worldDocs[indexPath.row]
                let controller = segue.destination as! WorldDocTableDetail
                controller.detailItem = object
                controller.title = object.data?.name
            }
        }
    }
    
    override func didMove(toParent parent: UIViewController?) {
      tableView.reloadData()
    }
}
