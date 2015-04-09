//
//  IBARateItemView.swift
//  iba
//
//  Created by Raymond kennedy on 4/8/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import Foundation


class IBARateItemView: UIView {

    var currentValue: CGFloat = 0
    
    let kSliderPadding: CGFloat = 5
    let kLabelPadding: CGFloat = 5
    let kLabelTextSize: CGFloat = 17
    let kLabelTextWidth: CGFloat = 100
    
    let slider: UISlider
    let lowTextLabel: UILabel
    let highTextLabel: UILabel
    let titleLabel: UILabel
    let currentLabel: UILabel
    
    
    // MARK: Init Methods
    
    convenience init(title: String, lowText: String, highText: String) {
        self.init(frame: CGRectZero)
        self.lowTextLabel.text = lowText
        self.highTextLabel.text = highText
        self.titleLabel.text = title
    
        // Add the border
        self.layer.cornerRadius = 6.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGrayColor().CGColor

        self.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        // Configure the slider
        setupSlider()
        
        // Configure the labels
        setupLowTextLabel()
        setupHighTextLabel()
        setupTitleLabel()
        setupCurrentLabel()
    }
    
    override init(frame: CGRect) {
        
        // Setup the slider
        self.slider = UISlider()
        
        // Setup the low text labels
        self.lowTextLabel = UILabel(frame: CGRectZero)
        self.highTextLabel = UILabel(frame: CGRectZero)
        self.titleLabel = UILabel(frame: CGRectZero)
        self.currentLabel = UILabel(frame: CGRectZero)

        super.init(frame: frame)
    }


    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSlider() {
        let sliderCircleImage = UIImage(named: "slider_circle")
        self.slider.setThumbImage(sliderCircleImage, forState: .Normal)
        self.slider.addTarget(self, action:"sliderValueChanged:", forControlEvents: .ValueChanged)
        self.slider.addTarget(self, action: "sliderUp:", forControlEvents: .TouchUpInside)
        self.slider.addTarget(self, action: "sliderDown:", forControlEvents: .TouchDown)

        self.slider.value = 0.0
        self.currentValue = 0
        self.slider.minimumTrackTintColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        self.slider.maximumTrackTintColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        self.addSubview(self.slider)

    }
    
    func setupLowTextLabel() {
        self.lowTextLabel.font = UIFont(name: "HelveticaNeue-Light", size: kLabelTextSize)
        self.lowTextLabel.textColor = UIColor.blackColor()
        self.lowTextLabel.textAlignment = .Left
        self.addSubview(self.lowTextLabel)
    }
    
    func setupHighTextLabel() {
        self.highTextLabel.font = UIFont(name: "HelveticaNeue-Light", size: kLabelTextSize)
        self.highTextLabel.textColor = UIColor.blackColor()
        self.highTextLabel.textAlignment = .Right
        self.addSubview(self.highTextLabel)
    }
    
    func setupTitleLabel() {
        self.titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: kLabelTextSize)
        self.titleLabel.textColor = UIColor.blackColor()
        self.titleLabel.textAlignment = .Left
        self.addSubview(self.titleLabel)
    }
    
    func setupCurrentLabel() {
        self.currentLabel.font = UIFont(name: "HelveticaNeue-Light", size: kLabelTextSize)
        self.currentLabel.textColor = UIColor.lightGrayColor()
        self.currentLabel.textAlignment = .Right
        self.currentLabel.alpha = 0
        self.addSubview(self.currentLabel)
    }
    
    override func layoutSubviews() {
        
        // Setup the slider
        self.slider.bounds = CGRectMake(0, 0, self.frame.size.width - (kSliderPadding * 2), self.slider.bounds.size.height)
        self.slider.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        slider.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin | .FlexibleBottomMargin;
        self.slider.userInteractionEnabled = true
        
        let lowText: NSString = self.lowTextLabel.text! as NSString
        let lowTextSize: CGRect = lowText.boundingRectWithSize(CGSizeMake(self.bounds.size.width, self.bounds.size.height), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName : self.lowTextLabel.font], context: nil)

        let highText: NSString = self.highTextLabel.text! as NSString
        let highTextSize: CGRect = highText.boundingRectWithSize(CGSizeMake(self.bounds.size.width, self.bounds.size.height), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName : self.highTextLabel.font], context: nil)

        let titleText: NSString = self.titleLabel.text! as NSString
        let titleTextSize: CGRect = titleText.boundingRectWithSize(CGSizeMake(self.bounds.size.width, self.bounds.size.height), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName : self.titleLabel.font], context: nil)

        // Setup the labels
        self.lowTextLabel.frame = CGRectMake(kLabelPadding, self.bounds.size.height - kLabelPadding - lowTextSize.height, kLabelTextWidth, lowTextSize.height)
        self.highTextLabel.frame = CGRectMake(self.bounds.size.width - kLabelPadding - highTextSize.width, self.bounds.size.height - kLabelPadding - highTextSize.height, highTextSize.width, highTextSize.height)
        self.titleLabel.frame = CGRectMake(kLabelPadding, kLabelPadding, titleTextSize.width, titleTextSize.height)
        self.currentLabel.frame = CGRectMake(self.bounds.size.width - kLabelPadding - 100, kLabelPadding, 100, titleTextSize.height)
        
    }
    
    func sliderValueChanged(sender: UISlider) {
        let percent: CGFloat = CGFloat(slider.value) * 100
        let percentString: String = String(format: "%.0f%%", Double(percent))
        self.currentLabel.text = percentString
        currentValue = CGFloat(self.slider.value)
    }
    
    func sliderDown(sender: UISlider) {
        self.currentLabel.alpha = 0.0
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.currentLabel.alpha = 1.0
        })
    }
    
    func sliderUp(sender: UISlider) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.currentLabel.alpha = 0.0
        })
    }
    
}