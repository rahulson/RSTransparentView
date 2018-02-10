//
//  RSTransparentView.swift
//  
//
//  Created by Mac Developer on 11/08/17.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import SnapKit

protocol RSTransparentViewDelegate {
    func RSTransparentViewDidClosed()
}

public enum RSStyle:Int{
    case RSStyleLight = 0
    case RSStyleBlack = 1
}

class RSTransparentView: UIView {

    
    private let kDefaultBackgroundColor = UIColor.init(white: 0.0, alpha: 0.7)
    
    var delegate:RSTransparentViewDelegate?
    var style:RSStyle? = .RSStyleLight
    var isCloseButtonHidden:Bool = false
    var isTapBackgroundClosedEnabled:Bool = false{
        didSet{
            tapBackGroundToClose(status: isTapBackgroundClosedEnabled)
        }
    }
    var isBlurEffectEnabled:Bool = false{
        didSet{
            setUseBlurConfig()
        }
    }
    var blurEffectStyle:UIBlurEffectStyle = .light
    
    private var blurEffect:UIBlurEffect?
    private var blurredView:UIView?{
        didSet{
            setBlurffEffectConfig()
        }
    }
    private var statusBarStyle:UIStatusBarStyle?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView(){
        self.frame = UIScreen.main.bounds
        self.isOpaque = false
        self.backgroundColor = kDefaultBackgroundColor
    }
    
    private func tapBackGroundToClose(status:Bool){
        if status{
            addTapGestureRecognizer()
        }
    
    }
    
    public func addStartButton(title:String){
        
        let roundView  = UIView.init()
        self.addSubview(roundView)
        roundView.backgroundColor = Style.colorAccent
        roundView.alpha = 0.6
        roundView.layer.cornerRadius = 55
        roundView.layer.masksToBounds = true
        roundView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
            make.width.height.equalTo(110)
        }
        
        let startButton = UIButton.init(type: .custom)
        self.addSubview(startButton)
        startButton.layer.cornerRadius = 45
        startButton.layer.masksToBounds = true
        startButton.backgroundColor = Style.colorAccentLight
        startButton.titleLabel?.numberOfLines = 0
        startButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        startButton.setTitle(title, for: .normal)
        startButton.titleLabel?.textColor = UIColor.white
        startButton.titleLabel?.textAlignment = .center
        startButton.titleLabel?.font = FONTConstants.TEXT_MEDIUM_FONT
        startButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
            make.width.height.equalTo(90)
        }
    }
    
 
    
    private func setBlurffEffectConfig(){
        if blurredView != nil && (Float(UIDevice.current.systemVersion)! > Float(8.0)){
            self.blurEffect = UIBlurEffect.init(style: self.blurEffectStyle)
            if self.blurredView?.superview != nil{
                self.blurredView?.removeFromSuperview()
            }
            self.blurredView = UIVisualEffectView.init(effect: self.blurEffect)
            self.blurredView?.frame = self.frame
            self.insertSubview(blurredView!, at: 0)
        }
    }
    
    private func setUseBlurConfig(){
        if isBlurEffectEnabled && (Float(UIDevice.current.systemVersion)! > Float(8.0)){
            if self.blurredView == nil{
                self.blurEffect = UIBlurEffect.init(style: self.blurEffectStyle)
                self.blurredView = UIVisualEffectView.init(effect: self.blurEffect)
                self.blurredView?.frame = self.frame
                self.insertSubview(blurredView!, at: 0)
            }else if self.blurredView?.superview == nil{
                self.insertSubview(blurredView!, at: 0)
            }
        }else if self.blurredView != nil{
            self.blurredView?.removeFromSuperview()
        }
        
    }
    
    public func show(){
        var window = UIApplication.shared.keyWindow
        if window == nil{
            window = UIApplication.shared.windows[0]
        }
        self.statusBarStyle = UIApplication.shared.statusBarStyle
        if !self.isCloseButtonHidden{
            let closebutton = UIButton.init(type: .custom)
            closebutton.frame = CGRect.init(x: self.frame.size.width - 60, y: 26, width: 50, height: 50)
            closebutton.addTarget(self, action: #selector(hide), for: .touchUpInside)
            self.addSubview(closebutton)
            
            var imageName:String?
            var statusBarStyle:UIStatusBarStyle = .default
            
            switch self.style!{
            case .RSStyleLight:
                imageName = "ic_close"
                statusBarStyle = .lightContent
                break
            case .RSStyleBlack:
                imageName = "ic_button_close_black"
                statusBarStyle = .default
                break
            }
            
            let image = UIImage.init(named: imageName!)
            closebutton.setImage(image, for: .normal)
            UIApplication.shared.statusBarStyle = statusBarStyle
        }
        
        let viewIn = CATransition.init()
        viewIn.duration = 0.4
        viewIn.type = kCATransitionReveal
        viewIn.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        self.layer.add(viewIn, forKey: kCATransitionReveal)
        window?.subviews[0].addSubview(self)
    }
    
    @objc public func hide(){
        let viewOut = CATransition.init()
        viewOut.duration = 0.3
        viewOut.type = kCATransitionFade
        viewOut.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.superview?.layer.add(viewOut, forKey: kCATransitionFade)
        UIApplication.shared.statusBarStyle = self.statusBarStyle!
        self.removeFromSuperview()
        delegate?.RSTransparentViewDidClosed()
    }
    

    
    private func addTapGestureRecognizer(){
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(close(sender:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func close(sender:UITapGestureRecognizer){
        self.hide()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
