//
//  TumblrURLGrabber.swift
//  lesAnimaux
//
//  Created by Aaron Boswell on 8/1/16.
//  Copyright © 2016 Aaron Boswell. All rights reserved.
//

import Foundation
class TumblrURLGrabber{
    
    static let sharedGrabber = TumblrURLGrabber()
    
    var imageQueue:ImageQueue?
    
    private let defaults = UserDefaults.standard

    private var timeOffsetArray: [Int]{
        get {
            return (defaults.object(forKey: "lesAnimaux.timeOffsetArray") ?? [NSDate().timeIntervalSince1970,NSDate().timeIntervalSince1970,NSDate().timeIntervalSince1970,NSDate().timeIntervalSince1970,NSDate().timeIntervalSince1970,NSDate().timeIntervalSince1970] ) as! [Int]
        }
        set {
            defaults.set(newValue, forKey: "lesAnimaux.timeOffsetArray")
        }
    }
    private var timeOffset: Int{
        get {
            return (defaults.object(forKey: "lesAnimaux.timeOffset") ?? NSDate().timeIntervalSince1970) as! Int
        }
        set {
            defaults.set(newValue, forKey: "lesAnimaux.timeOffset")
        }
    }
    
    private var tagArray: [String]{
        get {
            return (defaults.object(forKey: "lesAnimaux.tagArray") ?? ["catsofinstagram", "cutebunnies","cutepetclub","funnypets","petsofinstagram","cuteanimals" ] ) as! [String]
        }
        set {
            defaults.set(newValue, forKey: "lesAnimaux.tagArray")
        }
    }
    
    
    func getPictures() {
//        var date = NSDate(timeIntervalSince1970: TimeInterval(timeOffset))
//        date = date.addingTimeInterval(-60*60)
//        timeOffset = Int(date.timeIntervalSince1970)
        let url = URL(string: "https://api.tumblr.com/v2/tagged?tag=\(tagArray[0])&type=photo&api_key=fuiKNFp9vQFvjLNvx4sUwti4Yb5yGutBN4Xh10LXZhhRKjWlV4&before=\(timeOffsetArray[0])")
        //print("task")

        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data:Data?, response:URLResponse?, error: Error?) in
            if error != nil {
                print("error=\(error)")
                return
            }
            //print("response")
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                print(json["meta"]??["msg"])
                var dec = json as! [String:AnyObject]
                var response = dec["response"] as! [AnyObject]
                for post in response {
                    let photos = post as! [String:AnyObject]
                    if (photos["timestamp"] as! Int) < self.timeOffsetArray[0]{
                        self.timeOffsetArray[0] = photos["timestamp"] as! Int
                        print(self.timeOffsetArray[0])
                    }
                    
                    let tags = photos["tags"] as! [String]
                    if !clean(tags: tags){
                        //print("skipped")
                        continue
                    }else{
                        //print(tags)
                    }
                    
                    if let decode = photos["photos"] as? [AnyObject]{
                         //print(decode)
                        
                        for unit in decode {
                            if unit is [String:AnyObject]{
                                
                                
                                
                                var endDict = unit as! [String:AnyObject]
                                let urldic = endDict["original_size"]
                                
                                
                                var url = urldic as! [String:AnyObject]
                                
                                let urlString = url["url"] as! String
                                if self.imageQueue != nil{
                                    self.imageQueue!.downloadAndAdd(urlString: urlString)
                                    //print("Added: \(urlString)")
                                }else{
                                    print(urlString)
                                }
                                
                                
                                
                            }
                        }
                    }
                    
                }
            }catch{
                print("error")
            }
        })
        task.resume()
        
        
    }
    func cycle(){
        let first = timeOffsetArray.removeFirst()
        timeOffsetArray.append(first)
        let f = tagArray.removeFirst()
        tagArray.append(f)
    }
}


//Return true if all strings in tags are clean
func clean(tags:[String]) ->Bool{
    let badTags = ["blog","love","boy","girl","draw","porn","erotic","lady","alt","outfit","vegan","pokemon","paper","hipster","per","nak","face","creep","follow","daily","art","ill","fantasy","watercolor","sex","nsfw","vouge","queer","steampunk","asy","babies","selfie","suicide","tattoo","skin","fat","snap"]
    
    return mutuallyExclusiveIncludingSubstrings(array1: tags, array2: badTags)
}
func mutuallyExclusiveIncludingSubstrings(array1:[String], array2:[String]) -> Bool{
    for s1 in array1{
        for s2 in array2{
            if s1.range(of: s2) != nil{
                return false
            }
            if s2.range(of: s1) != nil{
                return false
            }
        }
    }
    return true
}
extension TumblrURLGrabber: ImageQueueUrlSource{
    func getUrls(){
        cycle()
        getPictures()
    }
}
