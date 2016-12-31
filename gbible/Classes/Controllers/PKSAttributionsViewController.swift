//
//  PKSAttributionsViewController.swift
//  gbible
//
//  Created by Kerri Shotts on 10/8/16.
//  Copyright © 2016 photoKandy Studios LLC. All rights reserved.
//

import UIKit
import SafariServices

class PKSAttributionsViewController: PKTableViewController {
  
  private var attributions = [
    (title: "AccessibleSegmentedController",
       extra: "© 2012 Wooji Juice",                uri: "http://www.wooji-juice.com/blog/segmented-control-accessibility.html"),
    (title: "AFNetworking",
       extra: "© 2016",                            uri: "http://afnetworking.com/"),
    (title: "Arev Sans",
       extra: "© Tavmjong Bah",                    uri: "http://tavmjong.free.fr/FONTS/"),
    (title: "Crashlytics",
       extra: "© 2015 Crashlytics, Inc.",          uri: "http://try.crashlytics.com"),
    (title: "Fabric",
       extra: "© 2015 Twitter, Inc.",              uri: "https://fabric.io"),
    (title: "FMDatabase",
       extra: "© Flying Meat Inc.",                uri: "https://github.com/ccgus/fmdb"),
    (title: "Font Awesome",
       extra: "© Dave Gandy",                      uri: "http://fortawesome.github.com/Font-Awesome/"),
    (title: "Gentium Plus",
       extra: "© 2003-2016 SIL International",     uri: "http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=Gentium_download"),
    (title: "iOS FontAwesome",
       extra: "© 2012 Alex Usbergo",               uri: "https://github.com/alexdrone/ios-fontawesome"),
    (title: "iRate",
       extra: "© 2011 Charcoal Design",            uri: "https://github.com/nicklockwood/iRate"),
    (title: "KOKeyboard",
       extra: "© 2012 Adam Horcek, Kuba Brecka",   uri: "https://github.com/adamhoracek/KOKeyboard"),
    (title: "New Athena Unicode",
       extra: "© American Philological Association", uri: "http://apagreekkeys.org/NAUdownload.html"),
    (title: "OpenDyslexic",
       extra: "© Abelardo Gonzalez",               uri: "http://opendyslexic.org/"),
    (title: "SegmentedControllerRevisted",
       extra: "© 2012 Marcus Crafter",             uri: "https://github.com/crafterm/SegmentedControlRevisited"),
    (title: "SVProgressHUD",
       extra: "© 2011 Samvermette",                uri: "https://github.com/samvermette/SVProgressHUD"),
    (title: "SSZipArchive",
       extra: "© 2015 Serhii Mumriak",             uri: "https://github.com/ZipArchive/ZipArchive"),
    (title: "UIColor-Expanded",
       extra: "© Erica Sadun",                     uri: "https://github.com/ars/uicolor-utilities"),
    (title: "UIViewController-KeyboardAdditions",
       extra: "© 2015 Andrew Podkovyrin",          uri: "https://github.com/podkovyrin/UIViewController-KeyboardAdditions"),
    (title: "ZUIIRevealController",
       extra: "© 2011 Philip Kluz",                uri: "https://github.com/pkluz/ZUUIRevealController"),
    (title: "Byzantine/Majority Text",
       extra: "Maurice A. Robinson, William G. Pierpoint, 2000 ed.", uri: "http://unbound.biola.edu/index.cfm?method=downloads.showDownloadMain"),
    (title: "Chapter counts",
       extra: "",                                  uri: "http://www.deafmissions.com/tally/bkchptrvrs.html"),
    (title: "Morphological parsing reference",
     extra: "Maurice A. Robinson, 2004",           uri: "http://www.byztxt.com/download/PARSINGS.TXT"),
    (title: "Strong's Greek Dictionary in XML",
       extra: "Ulrik Petersen",                    uri: "https://github.com/morphgnt/strongs-dictionary-xml"),
    (title: "Textus Receptus",
       extra: "Stephens 1550, Scrivener 1894",     uri: "http://unbound.biola.edu/index.cfm?method=downloads.showDownloadMain"),
    (title: "Tischendorf (unparsed)",
       extra: "Clint Yale, 8th Ed.",               uri: "http://unbound.biola.edu/index.cfm?method=downloads.showDownloadMain"),
    (title: "Westcott/Hort, UBS4 Variants",
       extra: "biblos.com",                        uri: "http://biblehub.com"),
    (title: "World English Bible",
       extra: "Michael Paul Johnson",              uri: "http://www.ebible.org"),
    (title: "Young's Literal Translation",
       extra: "Robert Young, 1862",                uri: "http://unbound.biola.edu/index.cfm?method=downloads.showDownloadMain"),
  ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  // MARK: - Table data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return attributions.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let reuseID = "PKSAttributionCell"
    var cell = tableView.dequeueReusableCell(withIdentifier: reuseID)
    if (cell == nil) {
      cell = UITableViewCell.init(style: .default, reuseIdentifier: reuseID)
    }
    
    cell!.textLabel?.text = attributions[indexPath.row].title
    cell!.detailTextLabel?.text = attributions[indexPath.row].extra
    return cell!
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let uri = attributions[indexPath.row].uri;
    if (uri != "") {
      let sfvc = SFSafariViewController.init(url: URL(string: uri)!)
      sfvc.modalPresentationStyle = .pageSheet
      present(sfvc, animated: true, completion: nil)
      tableView.deselectRow(at: indexPath, animated: true)
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
