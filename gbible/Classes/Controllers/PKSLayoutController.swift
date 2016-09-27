//
//  PKSLayoutController.swift
//  gbible
//
//  Created by Kerri Shotts on 9/12/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import UIKit

@objc class PKSLayoutController: UIViewController {

  @IBOutlet weak var lblTheme: UILabel!
  
  @IBOutlet weak var sgcTheme: UISegmentedControl!
  
  @IBOutlet weak var lblTextSize: UILabel!
  
  @IBOutlet weak var spnTextSize: UIStepper!
  
  @IBAction func textFontSizeChanged(_ sender: UIStepper) {
    PKSettings.instance().textFontSize = Int32(sender.value)
    updateSettings()
    NotificationCenter.default.post(name: noticeAppSettingsChanged, object: nil)
  }
  
  @IBAction func themeChanged(_ sender: UISegmentedControl) {
    PKSettings.instance().textTheme = Int32(sender.selectedSegmentIndex)
    updateSettings()
    PKAppDelegate.sharedInstance().updateAppearanceForTheme()
    NotificationCenter.default.post(name: noticeAppSettingsChanged, object: nil)
  }

  var sbvc: PKSimpleBibleViewController?
  
  func updateSettings() {
    PKSettings.instance().save()

    lblTheme.text = "\(__T("Theme")!) \(PKSettings.instance().textTheme + 1)"
    sgcTheme.selectedSegmentIndex = Int(PKSettings.instance().textTheme)
    
    lblTextSize.text = "\(PKSettings.instance().textFontSize)pt"
    spnTextSize.value = Double(PKSettings.instance().textFontSize)

    if (sbvc != nil) {
      sbvc!.loadChapter()
      sbvc!.scroll(toVerse: 0)
      sbvc!.updateAppearanceForTheme()
    }
    
    self.updateAppearanceForTheme()
    

  }
  
  func updateAppearanceForTheme() {
    self.view.backgroundColor = PKSettings.pkPageColor()
    self.view.tintColor = PKSettings.pkTintColor()
    lblTheme.textColor = PKSettings.pkTextColor()
    lblTextSize.textColor = PKSettings.pkTextColor()
  }
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func done(_ sender: AnyObject?) {
    self.dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(onSettingsChanged), name: noticeAppSettingsChanged, object: nil)
    self.updateAppearanceForTheme()
  }

  func onSettingsChanged() {
    self.updateSettings()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateSettings()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "SimpleBibleSegue") {
      sbvc = segue.destination as? PKSimpleBibleViewController
      sbvc!.incognito = true
      sbvc!.loadChapter(1, forBook: 62)

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
