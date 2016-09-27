//
//  PKSLayoutTextSelectionController.swift
//  gbible
//
//  Created by Kerri Shotts on 9/26/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import UIKit

class PKSLayoutTextSelectionController: PKSLayoutSingleSettingController {
  
  private var sourceTextNames: Array<String> = []
  private var glossTextNames: Array<String> = []
  private var sourceTextIDs: Array<Int> = []
  private var glossTextIDs: Array<Int> = []
  
  private func loadBibles() {
    sourceTextNames = PKBible.availableOriginalTexts(PK_TBL_BIBLES_NAME) as! Array<String>
    glossTextNames = PKBible.availableHostTexts(PK_TBL_BIBLES_NAME) as! Array<String>
    sourceTextIDs = PKBible.availableOriginalTexts(PK_TBL_BIBLES_ID) as! Array<Int>
    glossTextIDs = PKBible.availableHostTexts(PK_TBL_BIBLES_ID) as! Array<Int>
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    loadBibles()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (setting == "greek-text") ? sourceTextNames.count : glossTextNames.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let reuseID = "PKSBibleTitleCellId"
    var cell = tableView.dequeueReusableCell(withIdentifier: reuseID)
    if (cell == nil) {
      cell = UITableViewCell.init(style: .default, reuseIdentifier: reuseID)
    }
    
    cell!.textLabel?.text = (setting == "greek-text") ? sourceTextNames[indexPath.row]
                                                      : glossTextNames[indexPath.row]
    cell!.tag = (setting == "greek-text") ? sourceTextIDs[indexPath.row] : glossTextIDs[indexPath.row]
    
    let curText = (setting == "greek-text") ? PKSettings.instance().greekText : PKSettings.instance().englishText
    cell!.accessoryType = (Int(curText) == cell!.tag)  ? .checkmark : .none
    return cell!
  }
  
  
  // MARK: - Table delgate
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
