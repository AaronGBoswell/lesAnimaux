//
//  ViewController.swift
//  lesAnimaux
//
//  Created by Aaron Boswell on 7/23/16.
//  Copyright © 2016 Aaron Boswell. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var c = UIColor.blue()
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.backgroundColor = UIColor.black()
        if let filePath = ImageQueue.sharedQueue.nextInQueue(sender: self){
            setupImageViewWithPath(fileURL: filePath)

        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func touchUpInside(_ sender: AnyObject) {
        if activityIndicator.isAnimating(){
            return
        }
        swipeToNextView()
    }
    
    func tapRecognized(sender:AnyObject?) {
        swipeToNextView()
    }
    
    func swipeToNextView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController!.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupImageViewWithPath(fileURL:String){
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapRecognized(sender:)))
        recognizer.numberOfTouchesRequired = 1
        recognizer.numberOfTapsRequired = 1
        contentView.addGestureRecognizer(recognizer)
        
        activityIndicator.stopAnimating()
        imageView.image = UIImage(contentsOfFile: fileURL)
        imageView.contentMode = .scaleAspectFit
    }


}
extension ViewController:ImageQueueObserver{
    func receiveURL(fileURL: String) {
        setupImageViewWithPath(fileURL: fileURL)
    }
}

