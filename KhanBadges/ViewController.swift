//
//  ViewController.swift
//  KhanBadges
//
//  Created by Grant Hyun Park on 12/15/15.
//  Copyright © 2015 Grant Hyun Park. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON
import MBProgressHUD

class ViewController: UIViewController {
    
    //MARK: IBActions/IBOutlets
    
    // This is the UI for when no internet connection exists
    @IBAction func refresh(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            self.getCategories()
            self.getAllBadges()
        }
    }
    @IBOutlet var refreshButton: UIButton!
    @IBOutlet var theStackView: UIStackView!
    
    // The correct category index will be chosen so that the following view controller will have the right badge set.
    @IBOutlet weak var challengePatch: UIButton!
    @IBAction func challengePressed(sender: AnyObject) {
        self.selectedCategory = 5
        self.performSegueWithIdentifier("toTable", sender: self)
    }
    @IBOutlet weak var blackHoleBadge: UIButton!
    @IBAction func blackHolePressed(sender: AnyObject) {
        self.selectedCategory = 4
        self.performSegueWithIdentifier("toTable", sender: self)
    }
    @IBOutlet weak var sunBadge: UIButton!
    @IBAction func sunPressed(sender: AnyObject) {
        self.selectedCategory = 3
        self.performSegueWithIdentifier("toTable", sender: self)
    }
    @IBOutlet weak var earthBadge: UIButton!
    @IBAction func earthPressed(sender: AnyObject) {
        self.selectedCategory = 2
        self.performSegueWithIdentifier("toTable", sender: self)
    }
    @IBOutlet weak var moonBadge: UIButton!
    @IBAction func moonPressed(sender: AnyObject) {
        self.selectedCategory = 1
        self.performSegueWithIdentifier("toTable", sender: self)
    }
    @IBOutlet weak var meteoriteBadge: UIButton!
    @IBAction func meteoritePressed(sender: AnyObject) {
        self.selectedCategory = 0
        self.performSegueWithIdentifier("toTable", sender: self)
    }
    
    //MARK: Variables
    
    // This is set when the user chooses a category (AKA presses a button)
    var selectedCategory: Int = 0
    
    // Array of category buttons
    var arrayOfBadges:[UIButton] = []
    
    // Array of category descriptions
    var arrayOfDescriptions: [String] = []
    
    // JSON Data
    var jsonData: JSON?
    
    //MARK: viewDidLoad()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Will iterate over this array of buttons
        arrayOfBadges.append(meteoriteBadge)
        arrayOfBadges.append(moonBadge)
        arrayOfBadges.append(earthBadge)
        arrayOfBadges.append(sunBadge)
        arrayOfBadges.append(blackHoleBadge)
        arrayOfBadges.append(challengePatch)
        
        // Buttons are disabled until the categories have been populated.
        for each in arrayOfBadges {
            each.userInteractionEnabled = false
        }
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            // Populate the first view with the 6 different categories.
            self.getCategories()
            
            // Preparing the rest of the badges for viewing upon the user's selection of a category.
            self.getAllBadges()
        }
        
        // Sprucing up some UI
        for each in arrayOfBadges {
            each.imageView?.layer.masksToBounds = false
            each.imageView?.layer.shadowColor = UIColor.blackColor().CGColor
            each.imageView?.layer.shadowRadius = 7.0
            each.imageView?.layer.shadowOpacity = 0.75
            each.imageView?.sizeThatFits(CGSizeMake(70.0, 70.0))
            each.contentMode = UIViewContentMode.Center
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.refreshButton.hidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Manager Functions
    
    // Using a singleton to handle REST
    func getCategories() {
        APIManager.sharedInstance.getCategories { (json) -> Void in
            if json == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.theStackView.alpha = 0.0
                    self.refreshButton.hidden = false
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.theStackView.alpha = 1.0
                    self.refreshButton.hidden = true
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    for (var i=0; i<6; i++) {
                        if let jsonToString = json[i]["large_icon_src"].rawString() {
                            let theURL = NSURL(string: jsonToString)
                            self.arrayOfBadges[i].sd_setImageWithURL(theURL, forState: .Normal)
                        } else {
                            print("Something went wrong...")
                        }
                        if let description = json[i]["description"].rawString() {
                            self.arrayOfDescriptions.append(description)
                        } else {
                            print("Something went wrong...")
                        }
                    }
                })
            }
        }
    }
    
    // Using the singleton to handle REST
    func getAllBadges() {
        APIManager.sharedInstance.getBadges { (json) -> Void in
            if json == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.theStackView.alpha = 0.0
                    self.refreshButton.hidden = false
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                })
            } else {
                self.jsonData = json
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.theStackView.alpha = 1.0
                    self.refreshButton.hidden = true
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                })
                // Enable the buttons.
                for each in self.arrayOfBadges {
                    each.userInteractionEnabled = true
                }
            }
        }
    }
    
    //MARK: PrepareForSegue
    
    // Transferring the badges in the appropriate category to the next view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let table = segue.destinationViewController as! TableOfBadgesController
        table.jsonData = self.jsonData
        switch(self.selectedCategory) {
        case 0:
            table.categoryIndex = 0
            table.theTitle = "Meteorite Badges"
            table.aDescription = self.arrayOfDescriptions[0]
        case 1:
            table.categoryIndex = 1
            table.theTitle = "Moon Badges"
            table.aDescription = self.arrayOfDescriptions[1]
        case 2:
            table.categoryIndex = 2
            table.theTitle = "Earth Badges"
            table.aDescription = self.arrayOfDescriptions[2]
        case 3:
            table.categoryIndex = 3
            table.theTitle = "Sun Badges"
            table.aDescription = self.arrayOfDescriptions[3]
        case 4:
            table.categoryIndex = 4
            table.theTitle = "Black Hole Badges"
            table.aDescription = self.arrayOfDescriptions[4]
        case 5:
            table.categoryIndex = 5
            table.theTitle = "Challenger Patches"
            table.aDescription = self.arrayOfDescriptions[5]
        default:
            table.theTitle = "Khan Academy"
        }
    }

}