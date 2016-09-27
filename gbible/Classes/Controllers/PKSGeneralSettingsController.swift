//
//  PKSGeneralSettingsController.swift
//  gbible
//
//  Created by Kerri Shotts on 9/26/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import UIKit
import SafariServices

class PKSGeneralSettingsController: PKTableViewController {
  
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
      let blvc: PKBibleListViewController = PKBibleListViewController.init(style: .plain)
      navigationController?.pushViewController(blvc, animated: true)
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
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
