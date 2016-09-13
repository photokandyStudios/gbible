//
//  PKSLayoutController.swift
//  gbible
//
//  Created by Kerri Shotts on 9/12/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import UIKit

class PKSLayoutController: UIViewController {

  @IBOutlet weak var lblTheme: UILabel!
  
  @IBOutlet weak var sgcTheme: UISegmentedControl!
  
  @IBOutlet weak var lblTextSize: UILabel!
  
  @IBOutlet weak var spnTextSize: UIStepper!
  
  @IBAction func textFontSizeChanged(sender: UIStepper) {
    PKSettings.instance().textFontSize = Int32(sender.value)
    updateSettings()
  }
  
  @IBAction func themeChanged(sender: UISegmentedControl) {
    PKSettings.instance().textTheme = Int32(sender.selectedSegmentIndex)
    updateSettings()
    PKAppDelegate.sharedInstance().updateAppearanceForTheme()
  }

  var sbvc: PKSimpleBibleViewController?
  
  func updateSettings() {
    PKSettings.instance().saveSettings()

    lblTheme.text = "\(__T("Theme")) \(PKSettings.instance().textTheme + 1)"
    sgcTheme.selectedSegmentIndex = Int(PKSettings.instance().textTheme)
    
    lblTextSize.text = "\(PKSettings.instance().textFontSize)pt"
    spnTextSize.value = Double(PKSettings.instance().textFontSize)

    if (sbvc != nil) {
      sbvc!.loadChapter()
      sbvc!.scrollToVerse(0)
      sbvc!.updateAppearanceForTheme()
    }
    
    self.updateAppearanceForTheme()
    
    NSNotificationCenter.defaultCenter().postNotificationName(noticeAppSettingsChanged, object: nil)

  }
  
  func updateAppearanceForTheme() {
    self.view.backgroundColor = PKSettings.PKPageColor()
    self.view.tintColor = PKSettings.PKTintColor()
    lblTheme.textColor = PKSettings.PKTextColor()
    lblTextSize.textColor = PKSettings.PKTextColor()
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    updateSettings()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "SimpleBibleSegue") {
      sbvc = segue.destinationViewController as? PKSimpleBibleViewController
      sbvc!.incognito = true
      sbvc!.loadChapter(1, forBook: 40)
    }
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
