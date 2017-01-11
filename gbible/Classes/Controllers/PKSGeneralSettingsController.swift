//
//  PKSGeneralSettingsController.swift
//  gbible
//
//  Created by Kerri Shotts on 9/26/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import UIKit
import SafariServices

class PKSGeneralSettingsController: PKTableViewController, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
  
  private var importMode = 0;
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func done(_ sender: AnyObject?) {
    self.dismiss(animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.backgroundColor = PKSettings.pkSecondaryPageColor();
    cell.textLabel?.textColor = PKSettings.pkTextColor();
    cell.detailTextLabel?.textColor = PKSettings.pkTextColor();
    
    if (cell.tag == 401) {
      cell.detailTextLabel?.text = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    if (cell.tag == 301) {
      cell.accessoryType = PKSettings.instance().usageStats ? .checkmark : .none
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    
    switch (cell!.tag) {
    case 101:
      // Manage Bibles
      let blvc: PKBibleListViewController = PKBibleListViewController.init(style: .grouped)
      navigationController?.pushViewController(blvc, animated: true)
      break
      
    case 201:
      // export
      let pathToExportedFile = PKDatabase.instance().exportAll();
      if (pathToExportedFile != nil) {
        let url = URL(string: pathToExportedFile!)
        if (url != nil) {
          let dmvc = UIDocumentMenuViewController.init(url: url!, in: .exportToService)
          dmvc.delegate = self
          dmvc.modalPresentationStyle = .formSheet
          present(dmvc, animated: true, completion: nil)
        }
      }
      // and let the user export it to a service
      break
    
    case 202, 203:
      // the tag specifies the import mode; 0 = content, 1 = settings
      importMode = (cell!.tag - 202)
      
      // import
      let dmvc = UIDocumentMenuViewController.init(documentTypes: ["com.photokandy.gbible.userdata"], in: .import)
      dmvc.delegate = self
      dmvc.modalPresentationStyle = .formSheet
      present(dmvc, animated: true, completion: nil)
      break
      
    case 301:
      // toggle the usage stats
      PKSettings.instance().usageStats = !PKSettings.instance().usageStats;
      PKSettings.instance().save()
      PKSettings.instance().reload()
      tableView.reloadData()
      break
      
    case 302:
      // Privacy Notice
      let url = URL(string: "https://www.photokandy.com/apps/greek-interlinear-bible/privacy/")
      let sfvc = SFSafariViewController.init(url: url!)
      sfvc.modalPresentationStyle = .pageSheet
      present(sfvc, animated: true, completion: nil)
      break
      
    case 402:
      // Submit an issue...
      let url = URL(string: "https://github.com/photokandyStudios/gbible/issues")
      let sfvc = SFSafariViewController.init(url: url!)
      sfvc.modalPresentationStyle = .pageSheet
      present(sfvc, animated: true, completion: nil)
      break
      
    case 403:
      // Using the app...
      let avc:PKAboutViewController = PKAboutViewController.init()
      navigationController?.pushViewController(avc, animated: true)
      break
      
    case 404:
      // Rate this app...
      iRate.sharedInstance().promptIfNetworkAvailable()
      break
      
    default:
      break
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
    documentPicker.delegate = self
    present(documentPicker, animated: true, completion: nil)
  }

  func documentMenuWasCancelled(_ documentMenu: UIDocumentMenuViewController) {
    //?
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
    if (controller.documentPickerMode == .exportToService) {
      // export
    } else if (controller.documentPickerMode == .import) {
      // import
      var success = false
      let error = UIAlertController.init(title: __T("Import Error"), message: __T("error-import-failed"), preferredStyle: .alert)
      error.addAction(UIAlertAction.init(title: __T("OK"), style: .default, handler: nil))
      if (importMode == 0) {
        success = PKDatabase.instance().importNotes(from: url)
        if (success) {
          success = PKDatabase.instance().importHighlights(from: url)
          NotificationCenter.default.post(name: noticeAppSettingsChanged, object: nil)
        }
      } else {
        success = PKDatabase.instance().importSettings(from: url)
        NotificationCenter.default.post(name: noticeAppSettingsChanged, object: nil)
      }
      if (!success) {
        present(error, animated: true, completion: nil)
      }
    }
  }
  
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    if (controller.documentPickerMode == .exportToService) {
      // export cancelled
    } else if (controller.documentPickerMode == .import) {
      // import cancelled
    }
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
