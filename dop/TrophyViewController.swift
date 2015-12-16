//
//  TrophyViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 9/30/15.
//  Copyright © 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit

class TrophyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIAlertViewDelegate {
    
    @IBOutlet weak var collection_view: UICollectionView!
    
    var trophy_list = [TrophyModel]()
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = collection_view.frame.width / 3
        return CGSizeMake(size, size)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("trophy_identifier", forIndexPath: indexPath) as! TrophyCollectionCell

        
        return cell
    }
    
    func launchBadgeAlert() {
        self.presentViewController(AlertClass().launchAlert(), animated: true, completion: nil)
    }
    
}
