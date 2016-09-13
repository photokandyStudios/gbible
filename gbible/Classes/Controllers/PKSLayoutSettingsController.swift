//
//  PKSLayoutSettingsController.swift
//  gbible
//
//  Created by Kerri Shotts on 9/12/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import UIKit

class PKSLayoutSettingsController: PKTableViewController {
  
  @IBOutlet weak var lblSourceTextFont: UILabel!
  
  @IBOutlet weak var lblSourceText: UILabel!
  
  @IBOutlet weak var tglTransliterate: UITableViewCell!
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    NotificationCenter.default.addObserver(self, selector: #selector(onSettingsChanged), name: noticeAppSettingsChanged, object: nil)
    updateSettings()
  }
  
  func updateSettings() {
    lblSourceText.text = PKBible.title(forTextID: PKSettings.instance().greekText)
    lblSourceTextFont.text = PKSettings.instance().textGreekFontFace
    tglTransliterate.accessoryType = PKSettings.instance().transliterateText ? .checkmark : .none
  
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
    // Dispose of any resources that can be recreated.
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
