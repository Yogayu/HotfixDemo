//
//  SwiftViewController.swift
//  HotfixDemo
//
//  Created by youxinyu on 16/8/5.
//  Copyright © 2016年 yogayu.github.io. All rights reserved.
//

import UIKit

class SwiftViewController: UIViewController {

    var number = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        let testObject = TestObject()
        testObject.testLog()
        self.testLog()
    }

    func setUI() {
        let colorBtn = UIButton(frame: CGRect(x: 70, y: 10, width: 100, height: 200))
        colorBtn.backgroundColor = UIColor.yellowColor()
        view.addSubview(colorBtn)
    }
    
    dynamic func testLog() {
        print("ViewController orig testLog")
    }
    
}
