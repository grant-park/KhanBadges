//
//  TableOfBadgesController.swift
//  KhanBadges
//
//  Created by Grant Hyun Park on 12/15/15.
//  Copyright © 2015 Grant Hyun Park. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON
import NMPopUpViewSwift

class TableOfBadgesController: UIViewController {
        
    //MARK: IBActions/IBOutlets
    
    @IBOutlet var collectionView: UICollectionView!
    @IBAction func searchPressed(sender: AnyObject) {
        state = .SearchMode
    }
    
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet weak var categoryDescription: UILabel!
    @IBOutlet var theBar: UINavigationItem!
    @IBOutlet weak var theView: UIView!
    
    //MARK: Variables
    
    
    // Data Elements
    var categoryIndex: Int = 0
    var jsonData: JSON?
    var theData: NSArray?
    var theFilteredData: NSArray?
    var permData: NSArray?
    
    // UI Elements
    let searchBar: UISearchBar = UISearchBar(frame: CGRectMake(0.0,0.0,310.0,44.0))
    let searchBarView: UIView = UIView(frame: CGRectMake(0.0,0.0,310,44))
    var aDescription: String = ""
    var theTitle: String = ""
    var popViewController: PopUpViewControllerSwift!
    let defaultCenter: NSNotificationCenter = NSNotificationCenter()
    
    
    // State of the view controller (either searching or default)
    var state: State = .DefaultMode {
        didSet {
            switch(state) {
            case .DefaultMode:
                theBar.titleView = nil
                theBar.hidesBackButton = false
                theBar.rightBarButtonItem = searchButton
                theBar.title = theTitle
                searchBar.setShowsCancelButton(false, animated: true)
                searchBar.resignFirstResponder()
                searchBar.text = ""
            case .SearchMode:
                theBar.hidesBackButton = true
                theBar.rightBarButtonItem = nil
                theBar.titleView = searchBarView
                searchBar.setShowsCancelButton(true, animated: true)
                searchBar.becomeFirstResponder()
            }
        }
    }
    
    // Using enumeration logic for the states
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    //MARK: viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Converting JSON data to a NSArray for use of NSPredicate later on
        theData = try! NSJSONSerialization.JSONObjectWithData((jsonData!.rawData()), options: []) as! NSArray
        
        // Making sure the badges shown in this view controller are in the correct category
        let theCategoryPredicate: NSPredicate = NSPredicate(format: "badge_category = %d", categoryIndex)
        let theFilteredArray: NSArray = theData!.filteredArrayUsingPredicate(theCategoryPredicate)
        theFilteredData = theFilteredArray
        permData = theFilteredArray
        
        // UI setup including animations during scrolling
        theBar.title = theTitle
        categoryDescription.text = aDescription
        defaultCenter.addObserverForName("stuffShouldHide", object: nil, queue: nil) { (notification) -> Void in
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x, self.collectionView.frame.origin.y - self.theView.frame.height, self.collectionView.frame.width, self.collectionView.frame.height + self.theView.frame.height)
                self.theView.frame = CGRectMake(self.theView.frame.origin.x, self.theView.frame.origin.y - self.theView.frame.height, self.theView.frame.width, self.theView.frame.height)
            })
        }
        defaultCenter.addObserverForName("stuffShouldUnhide", object: nil, queue: nil) { (notification) -> Void in
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.theView.frame = CGRectMake(self.theView.frame.origin.x, self.theView.frame.origin.y, self.theView.frame.width, self.theView.frame.height)
                self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x, self.collectionView.frame.origin.y, self.collectionView.frame.width, self.collectionView.frame.height)
            })
        }

        // UISearchBar setup
        searchBar.delegate = self
        let textField = searchBar.valueForKey("searchField") as? UITextField
        textField?.textColor = UIColor.whiteColor()
        searchBar.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        searchBar.searchBarStyle = .Minimal
        searchBar.barTintColor = UIColor.whiteColor()
        searchBar.backgroundColor = UIColor.orangeColor()
        searchBar.tintColor = UIColor.whiteColor()
        searchBarView.addSubview(searchBar)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Sprucing up UI with scrolling effect
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if state == .DefaultMode {
            if self.collectionView.panGestureRecognizer.translationInView(self.view).y < 0.0 {
                defaultCenter.postNotificationName("stuffShouldHide", object: self)
            } else {
                defaultCenter.postNotificationName("stuffShouldUnhide", object: self)
            }
        }
    }
}



extension TableOfBadgesController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return theFilteredData!.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("badge", forIndexPath: indexPath) as! BadgeCell
        
        // Diving into the "JSON" that was converted to a NSArray (the conversion was solely for the purpose of conveniently using NSPredicate)
        if theFilteredData?.count != 0 {
            if let firstLevel = theFilteredData![indexPath.row] as? NSDictionary {
                if let name = firstLevel["description"] {
                    cell.badgeTitle.text = name as? String
                }
                if let icons = firstLevel["icons"] as? NSDictionary {
                    if let email = icons["email"] {
                        cell.badgeImage.sd_setImageWithURL(NSURL(string: email as! String))
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // UI Logic to return to the default view (Assuming once the user has visibly seen the badged that was searched for, the UI doesn't need to stay in search mode)
        searchBar.resignFirstResponder()
        state = .DefaultMode
        theFilteredData = permData
        collectionView.reloadData()
        
        // Save the name and large image of the badge that was selected
        var theDescription: String = ""
        var theIcon: String = ""
        
        // Diving into the NSArray again; This would be easy with SwiftyJSON, but it's not worth the effort of converting from NSArray to JSON
        if let firstLevel = theFilteredData![indexPath.row] as? NSDictionary {
            if let safeDescription = firstLevel["safe_extended_description"] {
                theDescription = safeDescription as! String
            }
            if let icons = firstLevel["icons"] as? NSDictionary {
                if let large = icons["large"] {
                    theIcon = large as! String
                }
            }
        }
        
        //Below is the UI setup for a "Pop-up View" upon the user's selection of a badge. This popup will show a larger, better quality badge and its description.
        let manager: SDWebImageManager = SDWebImageManager()
        let bundle = NSBundle(forClass: PopUpViewControllerSwift.self)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad)
        {
            self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController_iPad", bundle: bundle)
            manager.downloadImageWithURL(NSURL(string: theIcon), options: .HighPriority, progress: nil, completed: { (image, error, cacheType, bool, url) -> Void in
                self.popViewController.showInView(self.view, withImage: image, withMessage: theDescription, animated: true)
            })
        } else
        {
            if UIScreen.mainScreen().bounds.size.width > 320 {
                if UIScreen.mainScreen().scale == 3 {
                    self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController_iPhone6Plus", bundle: bundle)
                    manager.downloadImageWithURL(NSURL(string: theIcon), options: .HighPriority, progress: nil, completed: { (image, error, cacheType, bool, url) -> Void in
                        self.popViewController.showInView(self.view, withImage: image, withMessage: theDescription, animated: true)
                    })
                    
                } else {
                    self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController_iPhone6", bundle: bundle)
                    manager.downloadImageWithURL(NSURL(string: theIcon), options: .HighPriority, progress: nil, completed: { (image, error, cacheType, bool, url) -> Void in
                        self.popViewController.showInView(self.view, withImage: image, withMessage: theDescription, animated: true)
                    })
                }
            } else {
                self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: bundle)
                manager.downloadImageWithURL(NSURL(string: theIcon), options: .HighPriority, progress: nil, completed: { (image, error, cacheType, bool, url) -> Void in
                    self.popViewController.showInView(self.view, withImage: image, withMessage: theDescription, animated: true)
                })
            }
        }
    }
}



extension TableOfBadgesController: UISearchBarDelegate {
    
    // Upon cancelling search, UI is returned to the default state along with the original data (which is stored in "permData")
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        theFilteredData = permData
        collectionView.reloadData()
        state = .DefaultMode    }
    
    // Upon pressing the search button in the keyboard, the view controller returns to its default state but instead of displaying the original data, it displays the results of the search
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        state = .DefaultMode
    }
    
    // Filters the display of search results in real time as the keyboard is typing; the use of NSPredicate here is the core reason for my choice of NSArrays earlier
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let thePredicate: NSPredicate = NSPredicate(format: "description contains %@", searchText)
        let theSecondPredicate: NSPredicate = NSPredicate(format: "badge_category = %d", categoryIndex)
        let theCompoundPredicate: NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [thePredicate,theSecondPredicate])
        let filteredArray: NSArray = theData!.filteredArrayUsingPredicate(theCompoundPredicate)
        theFilteredData = filteredArray
        
        collectionView.reloadData()
    }

}