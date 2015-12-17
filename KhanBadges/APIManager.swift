//
//  APIManager.swift
//  KhanBadges
//
//  Created by Grant Hyun Park on 12/15/15.
//  Copyright © 2015 Grant Hyun Park. All rights reserved.
//
import SwiftyJSON

// The singleton
typealias response = (JSON, NSError?) -> Void

class APIManager: NSObject {
    static let sharedInstance = APIManager()
    
    let badgesURL = "https://www.khanacademy.org/api/v1/badges"
    let categoriesURL = "https://www.khanacademy.org/api/v1/badges/categories"
    
    private override init() {}
    
    func getBadges(onCompletion: (JSON) -> Void) {
        let route = badgesURL
        getRequest(route, onCompletion: { json, err in
            if let error = err {
                onCompletion(nil)
                print(error)
            } else {
                onCompletion(json as JSON)
            }
        })
    }
    
    func getCategories(onCompletion: (JSON) -> Void) {
        let route = categoriesURL
        getRequest(route, onCompletion: { json, err in
            if let error = err {
                onCompletion(nil)
                print(error)
            } else {
                onCompletion(json as JSON)
            }
        })
    }
    
    func getRequest(path: String, onCompletion: response) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let anError = error {
                onCompletion(nil,anError)
            } else {
                let json:JSON = JSON(data: data!)
                onCompletion(json, error)
            }
        })
        task.resume()
    }
}