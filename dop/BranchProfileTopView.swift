//
//  BranchProfileTopView.swift
//  dop
//
//  Created by Edgar Allan Glez on 8/6/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class BranchProfileTopView: UIView {
    
    @IBOutlet weak var branchCover: UIImageView!
    @IBOutlet weak var branchLogo: UIImageView!
    @IBOutlet weak var branchProfileSegmented: SegmentedControl!

    @IBAction func followBranch(sender: AnyObject) {
        
        let params:[String: AnyObject] = [
            "branch_id" : String(stringInterpolationSegment: 1),
            "date" : "2015-01-01"]
        
        println(params)
        BranchProfileController.likeBranchWithSuccess(params,
            success: { (couponsData) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let json = JSON(data: couponsData)
                    println(json)
                })
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    println(error)
                })
        })

    }
}