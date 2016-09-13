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
  
  fileprivate
  var pages = [UIViewController]()

  // MARK: - View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
    self.dataSource = self
    
    let page1: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "PKSLayoutNavigationController")
    let page2: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "PKSGeneralSettingsNavigationController")
        
    pages.append(page1)
    pages.append(page2)
    
    setViewControllers([page1], direction: .forward, animated: false, completion: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(onSettingsChanged), name: noticeAppSettingsChanged, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if (layoutDelegate != nil) {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
        self.layoutDelegate!.didChangeLayout(nil)
      })
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func onSettingsChanged() {
    self.view.backgroundColor = PKSettings.pkPageColor()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  // MARK: - Page View Controller Delegate
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    let currentIndex = pages.index(of: viewController)!
    let previousIndex = abs((currentIndex - 1) % pages.count)
    return pages[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    let currentIndex = pages.index(of: viewController)!
    let nextIndex = abs((currentIndex + 1) % pages.count)
    return pages[nextIndex]
  }
  
  // MARK: - Page View Controller Data Source
  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return pages.count
  }
  
  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
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
