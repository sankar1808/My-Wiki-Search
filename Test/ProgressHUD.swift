//
//  ProgressHUD.swift
//  LHMCustomerApp
//
//  Created by Sankaranarayana Settyvari on 14/08/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

class ProgressHUD: UIVisualEffectView {
    
    var cancelButton: UIButton!
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .light)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        contentView.addSubview(activityIndictor)
        contentView.addSubview(label)
        activityIndictor.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let userInterface = UIDevice.current.userInterfaceIdiom
            
            var width: CGFloat = 0.0
            if(userInterface == .pad){
                //iPads
                
                width = superview.frame.size.width / 2.3
                
            }else if(userInterface == .phone){
                //iPhone
                
                width = superview.frame.size.width - 20
                
            }
            
            let height: CGFloat = 50.0
            self.frame = CGRect(x: superview.frame.size.width / 2 - width / 2,
                                y: superview.frame.height / 2 - height / 2,
                                width: width,
                                height: height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRect(x: 5,
                                            y: height / 2 - activityIndicatorSize / 2,
                                            width: activityIndicatorSize,
                                            height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(x: activityIndicatorSize + 5,
                                 y: 0,
                                 width: width - activityIndicatorSize - 15,
                                 height: height)
            //label.textColor = UIColor.gray
            label.textColor = self.hexStringToUIColor(hex: "#231F20")
            label.font = UIFont.boldSystemFont(ofSize: 16)
            
            //            cancelButton = UIButton(frame: CGRect(x:(label.frame.size.width-100)/2, y: label.frame.size.height-20, width:100, height: 20))
            //            cancelButton.setTitle("Cancel", for: UIControlState.normal)
            //            cancelButton.setTitleColor(self.hexStringToUIColor(hex: "#231F20"), for: UIControlState.normal)
            //            cancelButton.addTarget(self, action: #selector(cancelProgressBar), for: UIControlEvents.touchUpInside)
            //            cancelButton.isUserInteractionEnabled = true
            //            cancelButton.layer.cornerRadius = 5
            //            cancelButton.layer.borderWidth = 1
            //            cancelButton.layer.borderColor = UIColor.black.cgColor
            //            label.addSubview(cancelButton)
        }
    }
    
    
    func cancelProgressBar (sender:UIButton)
    {
        activityIndictor.removeFromSuperview()
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
    
    
}

