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

    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var noConnectionLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func infoPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "About", message: "The following third-party frameworks are used in this application: \n \n SDWebImage \n \n NMPopUpViewSwift \n \n MBProgressHUD \n \n SwiftyJSON", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Variables
    
    // This is set when the user chooses a category (AKA presses a button)
    var selectedCategory: Int = 0
    
    // JSON Data
    var jsonData: JSON?
    var categoryData: JSON?
    
    //MARK: viewDidLoad()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.hidden = true

        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            // Populate the first view with the 6 different categories.
            self.getCategories()
            
            // Preparing the rest of the badges for viewing upon the user's selection of a category.
            self.getAllBadges()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.refreshButton.hidden = true
        self.noConnectionLabel.hidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Manager Functions
    
    // Using a singleton to handle api call for the categories
    func getCategories() {
        APIManager.sharedInstance.getCategories { (json) -> Void in
            if json == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.noConnectionLabel.hidden = false
                    self.refreshButton.hidden = false
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.categoryData = json
                    self.noConnectionLabel.hidden = true
                    self.refreshButton.hidden = true
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                })
            }
        }
    }
    
    // Using the singleton to get all the badges
    func getAllBadges() {
        APIManager.sharedInstance.getBadges { (json) -> Void in
            if json == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.noConnectionLabel.hidden = false
                    self.refreshButton.hidden = false
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                })
            } else {
                self.jsonData = json
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView.hidden = false
                    self.noConnectionLabel.hidden = true
                    self.refreshButton.hidden = true
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    self.collectionView.reloadData()
                })
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
            table.aDescription = self.categoryData![0]["description"].rawString()!
        case 1:
            table.categoryIndex = 1
            table.theTitle = "Moon Badges"
            table.aDescription = self.categoryData![1]["description"].rawString()!
        case 2:
            table.categoryIndex = 2
            table.theTitle = "Earth Badges"
            table.aDescription = self.categoryData![2]["description"].rawString()!
        case 3:
            table.categoryIndex = 3
            table.theTitle = "Sun Badges"
            table.aDescription = self.categoryData![3]["description"].rawString()!
        case 4:
            table.categoryIndex = 4
            table.theTitle = "Black Hole Badges"
            table.aDescription = self.categoryData![4]["description"].rawString()!
        case 5:
            table.categoryIndex = 5
            table.theTitle = "Challenger Patches"
            table.aDescription = self.categoryData![5]["description"].rawString()!
        default:
            table.theTitle = "Khan Academy"
        }
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("categoryBadge", forIndexPath: indexPath) as! CategoryCell

        if let theData = categoryData {
            cell.image.sd_setImageWithURL(NSURL(string: theData[indexPath.row]["large_icon_src"].rawString()!))
            cell.aDescription.text = theData[indexPath.row]["type_label"].rawString()!
        }
        
        // Sprucing up the UI
        let theLayer = cell.image.layer
        theLayer.masksToBounds = false
        theLayer.shadowColor = UIColor.blackColor().CGColor
        theLayer.shadowRadius = 4.0
        theLayer.shadowOpacity = 0.75
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let theData = categoryData {
            return theData.count
        } else {
            return 6
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedCategory = indexPath.row
        self.performSegueWithIdentifier("toTable", sender: self)
    }
    
}