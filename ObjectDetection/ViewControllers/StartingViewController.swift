//
//  StartingViewController.swift
//  ObjectDetection
//
//  Created by Andrés Aguilar on 5/24/20.
//  Copyright © 2020 Y Media Labs. All rights reserved.
//

import UIKit

class StartingViewController: UIViewController {
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("initial")
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { (timer) in
            print("Timer fired: \(count)")
            count += 1
            if count == 10 {
                timer.invalidate()
            }
        }
        print("timer done")
            
    }
        
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


