//
//  BranchRankingViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit

@objc protocol RankingPageDelegate {
    optional func resizeRankingView(dynamic_height: CGFloat)
}

class BranchRankingViewController: UITableViewController {
    var delegate: RankingPageDelegate?
    
    var parent_view: BranchProfileStickyController!
    
    var cached_images: [String: UIImage] = [:]
    var ranking_array = [PeopleModel]()
    var offset = 5
    var new_data: Bool = false
    var added_values: Int = 0
    
    var loader: MMMaterialDesignSpinner!
    
    override func viewDidLoad() {
        self.tableView.alwaysBounceVertical = false
        self.tableView.scrollEnabled = false
        //        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.rowHeight = 60
        
        setupLoader()
    }
    
    func setupLoader(){
        loader = MMMaterialDesignSpinner(frame: CGRectMake(0,70,50,50))
        loader.center.x = self.view.center.x
        loader.lineWidth = 3.0
        loader.startAnimating()
        loader.tintColor = Utilities.dopColor
        self.view.addSubview(loader)
    }
    
    override func viewDidAppear(animated: Bool) {
        if ranking_array.count == 0 {
            getRanking()
        } else { setFrame() }
    }
    
    func setFrame() {
        //self.tableView.frame.size.height = self.tableView.contentSize.height
        delegate?.resizeRankingView!(self.tableView.contentSize.height)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let model: PeopleModel = ranking_array[indexPath.row]
        
        let view_controller = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileStickyController") as! UserProfileStickyController
        view_controller.user_id = model.user_id
        view_controller.is_friend = model.is_friend
        view_controller.operation_id = model.operation_id!
        view_controller.person = model
        self.parent_view.navigationController?.pushViewController(view_controller, animated: true)

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ranking_array.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PeopleCell = tableView.dequeueReusableCellWithIdentifier("PeopleCell", forIndexPath: indexPath) as! PeopleCell
        
        let model = self.ranking_array[indexPath.row]
        cell.loadItem(model, viewController: self)
        downloadImage(model, cell: cell, index: indexPath.row)
        
        return cell
    }
    
    func getRanking() {

        BranchProfileController.getBranchProfileRankingWithSuccess(parent_view.branch_id, success: { (data) -> Void in
            let json = JSON(data: data)
            
            for (_, subJson): (String, JSON) in json["data"] {
                let names = subJson["names"].string!
                let surnames = subJson["surnames"].string!
                let facebook_key = subJson["facebook_key"].string ?? "No Facebook Key"
                let user_id = subJson["user_id"].int!
                let company_id = subJson["company_id"].int ?? 0
//                let branch_id =  subJson["branch_id" ].int!
                let birth_date = subJson["birth_date"].string!
                let privacy_status = subJson["privacy_status"].int!
                let main_image = subJson["main_image"].string!
                let total_used = subJson["total_used"].int!
                let level = subJson["level"].int ?? 0
                let exp = subJson["exp"].double ?? 0
                let operation_id = subJson["operation_id"].int ?? 5
                let is_friend = subJson["is_friend"].bool!
                
                let model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: birth_date, facebook_key: facebook_key, privacy_status: privacy_status, main_image: main_image, total_used: total_used, level: level, exp: exp, is_friend: is_friend, operation_id: operation_id)
                
                if model.total_used != 0 {
                    self.ranking_array.append(model)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.ranking_array.sortInPlace({ $0.total_used > $1.total_used })
                self.reload()
                Utilities.fadeInFromBottomAnimation(self.tableView, delay: 0, duration: 1, yPosition: 20)
                Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)

            });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    Utilities.fadeOutViewAnimation(self.loader, delay: 0, duration: 0.3)
                })
        })
    }
    
    func reload() {
        self.tableView.reloadData()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.setFrame()
        })
    }
    
    func reloadWithOffset(parent_scroll: UICollectionView) {
        if ranking_array.count != 0 {
            BranchProfileController.getBranchProfileRankingOffsetWithSuccess(ranking_array.last!.user_id, branch_id: self.parent_view.branch_id, offset: offset, success: { (data) -> Void in
                let json = JSON(data: data)
                
                for (_, subJson): (String, JSON) in json["data"] {
                    let names = subJson["names"].string!
                    let surnames = subJson["surnames"].string!
                    let facebook_key = subJson["facebook_key"].string!
                    let user_id = subJson["user_id"].int!
                    let company_id = subJson["company_id"].int ?? 0
                    //                let branch_id =  subJson["branch_id" ].int!
                    let birth_date = subJson["birth_date"].string!
                    let privacy_status = subJson["privacy_status"].int!
                    let main_image = subJson["main_image"].string!
                    let total_used = subJson["total_used"].int!
                    let level = subJson["level"].int!
                    let exp = subJson["exp"].double!
                    let operation_id = subJson["operation_id"].int ?? 5
                    let is_friend = subJson["is_friend"].bool!
                    
                    let model = PeopleModel(names: names, surnames: surnames, user_id: user_id, birth_date: birth_date, facebook_key: facebook_key, privacy_status: privacy_status, main_image: main_image, total_used: total_used, level: level, exp: exp, is_friend: is_friend, operation_id: operation_id)
                    
                    self.ranking_array.append(model)
                    self.new_data = true
                    self.added_values++
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.reload()
                    if self.new_data { self.offset += self.added_values }
                    parent_scroll.finishInfiniteScroll()
                });
                },
                
                failure: { (error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        parent_scroll.finishInfiniteScroll()
                    })
            })
        } else { parent_scroll.finishInfiniteScroll() }
    }
    
    func downloadImage(model: PeopleModel, cell: PeopleCell, index: Int) {
        let url = NSURL(string: model.main_image)
        cell.user_image.alpha = 0
        Utilities.downloadImage(url!, completion: {(data, error) -> Void in
            if let image = data{
                dispatch_async(dispatch_get_main_queue()) {
                    cell.user_image.image = UIImage(data: image)
                    Utilities.fadeInViewAnimation(cell.user_image, delay: 0, duration: 1)
                    cell.setRankingPosition(index)
                }
            }else{
                print("Error")
            }
        })
    }
}

