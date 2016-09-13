//
//  PKSSettingsPageViewController.swift
//  gbible
//
//  Created by Kerri Shotts on 9/12/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import Foundation
import UIKit

class PKSSettingsPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
  
  var layoutDelegate: PKLayoutControllerDelegate?
  
  private
  var pages = [UIViewController]()

  // MARK: - View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
    self.dataSource = self
    
    let page1: UIViewController! = storyboard?.instantiateViewControllerWithIdentifier("PKSLayoutNavigationController")
    let page2: UIViewController! = storyboard?.instantiateViewControllerWithIdentifier("PKSGeneralSettingsNavigationController")
        
    pages.append(page1)
    pages.append(page2)
    
    setViewControllers([page1], direction: .Forward, animated: false, completion: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onSettingsChanged), name: noticeAppSettingsChanged, object: nil)
  }
  
  override func viewWillDisappear(animated: Bool) {
    onSettingsChanged()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self);
  }

  func onSettingsChanged() {
    if (layoutDelegate != nil) {
      layoutDelegate!.didChangeLayout(nil)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func unwindFromFromSettings(sender: UIStoryboardSegue) {
    if (layoutDelegate != nil) {
      layoutDelegate!.didChangeLayout(nil)
    }  
  }
  

  // MARK: - Page View Controller Delegate
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    let currentIndex = pages.indexOf(viewController)!
    let previousIndex = abs((currentIndex - 1) % pages.count)
    return pages[previousIndex]
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    let currentIndex = pages.indexOf(viewController)!
    let nextIndex = abs((currentIndex + 1) % pages.count)
    return pages[nextIndex]
  }
  
  // MARK: - Page View Controller Data Source
  func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return pages.count
  }
  
  func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    return 0
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

};
