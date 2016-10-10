//
//  PKSImportExportViewController.swift
//  gbible
//
//  Created by Kerri Shotts on 10/8/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import UIKit

class PKSImportExportViewController: PKTableViewController {
  
  private var importAnnotations = true
  private var importHighlights = true
  private var importSettings = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func alertUserWithTitle(_ title: String, message: String) {
    let ac = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    present(ac, animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let tag = cell.tag
    
    switch(tag) {
    case 101:
      cell.accessoryType = importAnnotations ? .checkmark : .none
      break
    case 102:
      cell.accessoryType = importHighlights ? .checkmark : .none
      break
    case 103:
      cell.accessoryType = importSettings ? .checkmark : .none
      break
    default:
      cell.accessoryType = .none
      break
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    let tag = cell?.tag ?? 0
    var success = true
    
    switch(tag) {
    case 101:
      importAnnotations = !importAnnotations
      tableView.reloadData()
      break
    case 102:
      importHighlights = !importHighlights
      tableView.reloadData()
      break
    case 103:
      importSettings = !importSettings
      tableView.reloadData()
      break
    case 901: /*
      success = PKDatabase.instance().exportAll()
      if (!success) {
        alertUserWithTitle(__T("Export Operation"), message: __T("Could not export data."))
      } else {
        alertUserWithTitle(__T("Export Operation"), message: __T("Done!"))
      }*/
      break
    case 902:
      break
    case 501:
/*      if (importAnnotations) {
        success = PKDatabase.instance().importNotes()
      }
      if (importHighlights && success) {
        success = PKDatabase.instance().importHighlights()
      }
      if (importSettings && success) {
        success = PKDatabase.instance().importSettings()
      }*/
      if (!success) {
        // failure
      } else {
        // success
        alertUserWithTitle(__T("Import Operation"), message: __T("Done!"))
      }
      break
    case 502:
      break
    default:
      break
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
