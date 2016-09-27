//
//  PKSLayoutSingleSettingController.swift
//  
//
//  Created by Kerri Shotts on 9/26/16.
//
//

import UIKit

class PKSLayoutSingleSettingController: PKTableViewController {
  
  var setting: String = ""
  var settingType: String = "list"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.backgroundColor = PKSettings.pkSecondaryPageColor();
    cell.textLabel?.textColor = PKSettings.pkTextColor();
    cell.detailTextLabel?.textColor = PKSettings.pkTextColor();
    if (settingType == "font") {
      cell.textLabel?.font = UIFont.init(name: cell.textLabel?.text, andSize: UIFont.systemFontSize)
      cell.accessoryType = PKSettings.instance().loadSetting(setting) == cell.textLabel?.text ? .checkmark : .none
    } else {
      cell.accessoryType = PKSettings.instance().loadSetting(setting) == String(cell.tag) ? .checkmark : .none
    }
  }
  
    /*
    // MARK: - Navigation
    */


  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let cell = sender as? UITableViewCell
    if (cell != nil) {
      if (settingType == "font") {
        PKSettings.instance().saveSetting(setting, valueForSetting: cell!.textLabel?.text)
      } else {
        PKSettings.instance().saveSetting(setting, valueForSetting: String(cell!.tag))
      }
      PKSettings.instance().reload()
      NotificationCenter.default.post(name: noticeAppSettingsChanged, object: nil)
    }
  }
}
