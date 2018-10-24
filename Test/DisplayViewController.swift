//
//  DisplayViewController.swift
//  Test
//
//  Created by Sankaranarayana Settyvari on 23/10/18.
//  Copyright © 2018 Qualityze Inc. All rights reserved.
//

import UIKit
import WebKit

class DisplayViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: WKWebView!
    var selectedString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = NSURL (string: selectedString)
        let request = NSURLRequest(url: url! as URL)
        self.webView.load(request as URLRequest)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
