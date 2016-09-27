//
//  PKSLayoutSettingsController.swift
//  gbible
//
//  Created by Kerri Shotts on 9/12/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import UIKit

class PKSLayoutSettingsController: PKTableViewController {
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    NotificationCenter.default.addObserver(self, selector: #selector(onSettingsChanged), name: noticeAppSettingsChanged, object: nil)
    updateSettings()
  }
  
  func updateSettings() {
    tableView.reloadData()
    NotificationCenter.default.post(name: noticeAppSettingsChanged, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func onSettingsChanged() {
    self.updateAppearanceForTheme()
    self.view.backgroundColor = PKSettings.pkPageColor()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func getCellTypeAndSetting(_ cell: UITableViewCell?)-> (type: String, setting: String, extras: String) {
    let accessibilityIdentifier = cell?.accessibilityIdentifier ?? ""
    let componentsSplitByColon = accessibilityIdentifier.components(separatedBy: ":")
    let cellType = componentsSplitByColon.first ?? ""
    let cellSetting = componentsSplitByColon.count > 1 ? componentsSplitByColon[1] : ""
    let cellExtras = componentsSplitByColon.count > 2 ? componentsSplitByColon[2] : ""
    return (type: cellType, setting: cellSetting, extras: cellExtras)
  }
  
  func getDictionaryFromList(_ list: String) -> Dictionary<String, String> {
    var dict: Dictionary<String, String> = Dictionary.init()
    let items = list.components(separatedBy: ";")
    for item in items {
      let parts = item.components(separatedBy: ",")
      let key = parts[0]
      let val = parts[1]
      dict[key] = val
    }
    return dict
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.backgroundColor = PKSettings.pkSecondaryPageColor();
    cell.textLabel?.textColor = PKSettings.pkTextColor();
    cell.detailTextLabel?.textColor = PKSettings.pkTextColor();
    let (type: cellType, setting:cellSetting, extras:cellExtras) = getCellTypeAndSetting(cell)
    switch cellType {
      case "BOOL":
        cell.accessoryType = PKSettings.instance().loadSetting(cellSetting) == "YES" ? .checkmark : .none
        break
      case "BIBLE":
        cell.detailTextLabel!.text = PKBible.title(forTextID: (cellSetting == "greek-text" ? PKSettings.instance().greekText : PKSettings.instance().englishText))
        break
      case "FONT":
        cell.detailTextLabel!.text = PKSettings.instance().loadSetting(cellSetting)
        break
      case "LIST":
        cell.detailTextLabel!.text = getDictionaryFromList(cellExtras)[PKSettings.instance().loadSetting(cellSetting)]
        break
      default:
        break
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    let (type: cellType, setting:cellSetting, extras:_) = getCellTypeAndSetting(cell)
    switch cellType {
      case "BOOL":
        PKSettings.instance().saveSetting(cellSetting, valueForSetting: PKSettings.instance().loadSetting(cellSetting) == "YES" ? "NO" : "YES")
        PKSettings.instance().reload()
        updateSettings()
        break
      case "BIBLE":
        // nothing; segue happens
        break
      case "FONT":
        // nothing; segue happens
        break
      case "LIST":
        // nothing; segue happens
        break
      default:
        break
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch (segue.identifier!) {
      case "SourceTypefaceSegue":
        (segue.destination as! PKSLayoutSingleSettingController).setting = "greek-typeface"
        break
      case "GlossTypefaceSegue":
        (segue.destination as! PKSLayoutSingleSettingController).setting = "font-face"
        break
      case "SourceBibleListSegue":
        (segue.destination as! PKSLayoutTextSelectionController).setting = "greek-text"
        break
      case "GlossBibleListSegue":
        (segue.destination as! PKSLayoutTextSelectionController).setting = "english-text"
        break
    default:
      break
    }
  }
  
  @IBAction func unwindFromSingleSetting(segue:UIStoryboardSegue) {
    
  }
}
