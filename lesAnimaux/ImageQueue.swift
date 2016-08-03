//
//  File.swift
//  lesAnimaux
//
//  Created by Aaron Boswell on 7/23/16.
//  Copyright © 2016 Aaron Boswell. All rights reserved.
//

import Foundation

class ImageQueue{
    static let sharedQueue = ImageQueue()
    
    var observer:ImageQueueObserver?
    var source:ImageQueueUrlSource?
    
    private var fileNumber: Int{
        get {
            return (defaults.object(forKey: "lesAnimaux.fileNumber") ?? 0 ) as! Int
        }
        set {
            defaults.set(newValue, forKey: "lesAnimaux.fileNumber")
        }
    }
    
    private var urls: [String]{
        get {
            return (defaults.object(forKey: "lesAnimaux.urls") ?? [String]() ) as! [String]
        }
        set {
            defaults.set(newValue, forKey: "lesAnimaux.urls")
        }
    }
    private let defaults = UserDefaults.standard

    func downloadAndAdd(urlString:String){
        DispatchQueue.global(qos: .background).async {
            let url = URL(string: urlString)!
            //let url = URL(fileURLWithPath: urlString)

                let task = URLSession.shared.dataTask(with: url, completionHandler: { (data:Data?, response:URLResponse?, error: Error?) in
                    if (error != nil){
                        print(error)
                    }
                    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let documentDirectory = paths[0]
                    let filePath = documentDirectory + "/\(self.fileNumber).png"
                    self.fileNumber += 1
                    let fileURL = URL(fileURLWithPath: filePath)
                    do{
                    try data!.write(to: fileURL)
                    } catch let error as NSError{
                        print(error)
                        print("An error has occured")
                    }
                    //print("Downloaded:\(urlString)")
                    
                    if (self.observer != nil){
                        DispatchQueue.main.async {
                            self.observer?.receiveURL(fileURL: filePath)
                            self.observer = nil
                        }
                    }else{
                        self.urls.append(filePath)
                    }
                })
                task.resume()
            
        }
    }
    func nextInQueue(sender:ImageQueueObserver? = nil) -> String?{
        if urls.isEmpty{
            
            observer = sender
            return nil
        }
        if urls.count < 10{
            source?.getUrls()
        }
        return urls.removeFirst()
    }
    
    
}
protocol ImageQueueObserver {
    func receiveURL(fileURL:String)
}
protocol ImageQueueUrlSource{
    func getUrls()
}
