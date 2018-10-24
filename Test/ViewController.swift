//
//  ViewController.swift
//  Test
//
//  Created by Sankaranarayana Settyvari on 22/10/18.
//  Copyright © 2018 Qualityze Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var searchTableView: UITableView  =   UITableView()
    var searchBarArray = NSMutableArray()
    var searchBarDisplayArray = NSMutableArray()
    var searchBarURLArray = NSMutableArray()
    var searchTitleArray = NSMutableArray()
    var searchThumbnailArray = NSMutableArray()
    var searchStoreArray = NSMutableArray()
    var searchDictionary = NSMutableDictionary()
    var search: Search = Search()
    var count:Int = 0
    var progressHUD = ProgressHUD(text:"")
    var progressView: UIView = UIView()
    var screenSize = CGRect(origin: .zero, size: .zero)
    var getString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.searchTextField.delegate = self
        self.searchTextField.returnKeyType = UIReturnKeyType.search
        self.searchBarArray = NSMutableArray()
        self.searchBarDisplayArray = NSMutableArray()
        self.searchBarURLArray = NSMutableArray()
        self.searchDictionary = NSMutableDictionary()
        self.searchStoreArray = NSMutableArray()
        self.searchTableView = UITableView(frame: CGRect(x: 0, y: 108, width: self.view.frame.size.width, height:self.view.frame.size.height-108))
        self.searchTableView.dataSource = self
        self.searchTableView.delegate = self
        self.searchTableView.rowHeight = 100
        self.searchTableView.bounces = false
        self.searchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        self.view.addSubview(self.searchTableView)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        
        dismissKeyboard()
        if (self.searchTextField.text?.count)! > 0
        {
            self.searchBarArray.removeAllObjects()
            self.searchBarDisplayArray.removeAllObjects()
            self.searchBarURLArray.removeAllObjects()
            self.searchStoreArray.removeAllObjects()
            self.searchDictionary.removeAllObjects()
            count = 0
            searchingList(searchString: self.searchTextField.text!)
        }
    }
    func displaySearchList()
    {
        self.progressView.removeFromSuperview()
        self.progressHUD.removeFromSuperview()
        
        for i in 0 ..< self.searchBarArray.count {
            self.search = Search()
            self.search._name = self.searchBarArray[i] as? String
            self.search._description = self.searchBarDisplayArray[i] as? String
            self.search._thumbnailURL = self.searchDictionary.value(forKey: self.searchBarArray[i] as! String) as? String
            self.search._pageURL = self.searchBarURLArray[i] as? String
            self.searchStoreArray.add(self.search)
        }
        self.searchTableView.reloadData()
       
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchStoreArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        let search: Search = self.searchStoreArray[indexPath.row] as! Search
        if(search._thumbnailURL != nil)
        {
            let imageURL = NSURL(string: search._thumbnailURL!)
            let imagedData = NSData(contentsOf: imageURL! as URL)!
            cell.imageView?.image = UIImage(data: imagedData as Data)
        }
        else
        {
            cell.imageView?.image = UIImage(named:"no-image.jpg")!
        }
        cell.textLabel?.text = search._name
        cell.detailTextLabel?.text = search._description
        cell.textLabel?.numberOfLines=0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // If you want to push to new ViewController then use this
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "Display") as! DisplayViewController
        let search: Search = self.searchStoreArray[indexPath.row] as! Search
        vc.selectedString = search._pageURL!
        // If you want to push to new ViewController then use this
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
    func searchingList(searchString:String)
    {
        self.screenSize = UIScreen.main.bounds
        self.progressView = UIView(frame: CGRect(x: 0, y: 0, width: self.screenSize.width, height: self.screenSize.height))
        let dimAlphaRedColor =  UIColor.gray.withAlphaComponent(0.5)
        self.progressView.backgroundColor =  dimAlphaRedColor
        self.view.addSubview(self.progressView)
        self.progressHUD = ProgressHUD(text: "Please wait searching for details")
        self.progressView.addSubview(self.progressHUD)
        getString = "https://en.wikipedia.org/w/api.php?action=opensearch&search="
        getString = getString.appending(searchString)
        getString = getString.appending("&limit=10&format=json")
        getString = getString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
        let urlString = URL(string: getString)!
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: urlString)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard data != nil else {
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if(statusCode == 200)
            {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    self.searchBarArray = (jsonResponse[1] as AnyObject).mutableCopy() as! NSMutableArray
                    self.searchBarDisplayArray = (jsonResponse[2] as AnyObject).mutableCopy() as! NSMutableArray
                    self.searchBarURLArray = (jsonResponse[3] as AnyObject).mutableCopy() as! NSMutableArray
                     DispatchQueue.main.async(){
                        self.displaySearchList()
                        self.loadImageURLs()
                    }
                    
                }
                catch let error
                {
                    print(error)
                }
            }
            
        })
        task.resume()
    }
    
    func loadImageURLs()
    {
        let group = DispatchGroup()
        group.enter()
        for i in 0 ..< self.searchBarArray.count {
            
            let storeString = self.searchBarArray[i] as! String
            getString = "https://en.wikipedia.org/w/api.php?action=query&titles="
            getString = getString.appending(storeString)
            getString = getString.appending("&prop=pageimages&limit=10&format=json")
            getString = getString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
            
            let urlString1 = URL(string: getString)!
            //create the session object
            let session = URLSession.shared
            
            //now create the URLRequest object using the url object
            var request = URLRequest(url: urlString1)
            request.httpMethod = "GET"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                
                guard error == nil else {
                    return
                }
                
                guard data != nil else {
                    return
                }
                
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if(statusCode == 200)
                {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                        let json = jsonResponse["query"] as! NSDictionary
                        let json1 = json["pages"] as! NSDictionary
                        let subDict = json1.allValues.first as? [String:Any] ?? [:]
                        if subDict["thumbnail"] != nil {
                            let json2 = subDict["thumbnail"] as! NSDictionary
                            let title = subDict["title"]
                            let url = json2["source"]
                            
                            self.searchDictionary.setValue(url!, forKey: title as! String)
                        } else {
                            let title = subDict["title"]
                            self.searchDictionary.setValue(nil, forKey: title as! String)
                        }
                        self.count = self.count + 1
                        if(self.count == self.searchBarArray.count)
                        {
                            DispatchQueue.main.async(){
                                self.searchStoreArray.removeAllObjects()
                                self.displaySearchList()
                            }
                        }
                        
                    }
                    catch let error
                    {
                        print(error)
                    }
                }
                
                
            })
            task.resume()
        }
        
        group.leave()
        
    }
    // UITextField Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.searchTextField{
            //self.dismiss(animated: true, completion: nil
        }

        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.searchTextField{
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        return true;
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField == self.searchTextField {
            
        }

        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when   'return' key pressed. return NO to ignore.
    {
        if textField == self.searchTextField {
            
            if (self.searchTextField.text?.count)! > 0
            {
                self.searchBarArray.removeAllObjects()
                self.searchBarDisplayArray.removeAllObjects()
                self.searchBarURLArray.removeAllObjects()
                self.searchStoreArray.removeAllObjects()
                self.searchDictionary.removeAllObjects()
                count = 0
                searchingList(searchString: self.searchTextField.text!)
            }
            
        }
        searchTextField.resignFirstResponder()
        return true;
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // text hasn't changed yet, you have to compute the text AFTER the edit yourself
        //let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        if textField == self.searchTextField
        {
            let aSet = NSCharacterSet(charactersIn:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            let maxLength = 20
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return (newLength <= maxLength && string == numberFiltered)
        }
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

