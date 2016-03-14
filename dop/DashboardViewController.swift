//
//  DashboardViewController.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 05/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.
//

import UIKit
import QuartzCore

class DashboardViewController: BaseViewController, CLLocationManagerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    @IBOutlet var trendingPageControl: UIPageControl!
    @IBOutlet var nearestPageControl: UIPageControl!
    @IBOutlet var mainLoader: MMMaterialDesignSpinner!
    @IBOutlet var toExpirePageControl: UIPageControl!
    @IBOutlet var nearestContainer: UIView!
    @IBOutlet var nearestScroll: UIScrollView!
    @IBOutlet var toExpireScroll: UIScrollView!
    @IBOutlet var toExpireContainer: UIView!
    @IBOutlet var mainScroll: UIScrollView!
    @IBOutlet var trendingContainer: UIView!
    @IBOutlet var trendingScroll: UIScrollView!
    @IBOutlet var pageControlContainer: UIView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var branchesScroll: UIScrollView!
    
    var locValue: CLLocationCoordinate2D?
    var refreshControl: UIRefreshControl!
    var coupons = [Coupon]()
    var branches = [Branch]()
    var trending = [Coupon]()
    var almost_expired = [Coupon]()
    var nearest = [Coupon]()
    var cachedImages: [String: UIImage] = [:]
    var locationManager: CLLocationManager!
    var obtained_location: Bool = false
    var updater: CADisplayLink? = nil
    var firstCallToUpdater: Bool = true
    var trendingLoader: MMMaterialDesignSpinner!
    var toexpireLoader: MMMaterialDesignSpinner!
    var nearestLoader: MMMaterialDesignSpinner!
    
    var firstTime: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLoader.startAnimating()
        mainLoader.tintColor = Utilities.dopColor
        mainLoader.lineWidth = 3.0
        
        mainScroll.contentSize = CGSizeMake(mainScroll.frame.size.width, 4500)
        mainScroll.delegate = self
        
        branchesScroll.delegate = self
        trendingScroll.delegate = self
        toExpireScroll.delegate = self
        nearestScroll.delegate = self
        
        branchesScroll.alpha = 0
        pageControlContainer.alpha = 0
        trendingContainer.alpha = 0
        toExpireContainer.alpha = 0
        nearestContainer.alpha = 0
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.mainScroll.addSubview(refreshControl)

        self.setNeedsStatusBarAppearanceUpdate()

        Utilities.printFonts()
        
        setupLoaders()
        
    }
    
    func setupLoaders(){
        trendingLoader = MMMaterialDesignSpinner(frame: CGRectMake(0, 0, 30, 30))
        trendingLoader.startAnimating()
        trendingLoader.lineWidth = 2.0
        trendingLoader.alpha = 0
        trendingLoader.tintColor = Utilities.dopColor
        
        toexpireLoader = MMMaterialDesignSpinner(frame: CGRectMake(0, 0, 30, 30))
        toexpireLoader.startAnimating()
        toexpireLoader.lineWidth = 2.0
        toexpireLoader.tintColor = Utilities.dopColor
        
        nearestLoader = MMMaterialDesignSpinner(frame: CGRectMake(0, 0, 30, 30))
        nearestLoader.startAnimating()
        nearestLoader.lineWidth = 2.0
        nearestLoader.tintColor = Utilities.dopColor

        self.getTopBranches()

    }
    

    override func viewDidAppear(animated: Bool) {
        if (updater) != nil { updater!.paused = false }
        
        trendingLoader.center.x = self.mainScroll.center.x
        trendingLoader.center.y = self.trendingContainer.center.y
        self.mainScroll.addSubview(trendingLoader)
        
        toexpireLoader.center.x = self.mainScroll.center.x
        toexpireLoader.center.y = self.toExpireContainer.center.y
        self.mainScroll.addSubview(toexpireLoader)
        
        nearestLoader.center.x = self.mainScroll.center.x
        nearestLoader.center.y = self.nearestContainer.center.y
        self.mainScroll.addSubview(nearestLoader)


        if firstTime==false{
            firstTime = true
            self.getTrendingCoupons()
            self.getToExpireCoupons()
        }
        
        

    }
    
    func refresh(sender:AnyObject) {
        getToExpireCoupons()
        getTrendingCoupons()
        getNearestCoupons()
        refreshControl.endRefreshing()
        
        trendingLoader.alpha = 1
        toexpireLoader.alpha = 1
        nearestLoader.alpha = 1
        self.trendingContainer.alpha = 0
        self.toExpireContainer.alpha = 0
        self.nearestContainer.alpha = 0
        
        trendingLoader.startAnimating()
        toexpireLoader.startAnimating()
        nearestLoader.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == branchesScroll { updater!.paused = false }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) { }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView == branchesScroll { updater!.paused = true }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        switch scrollView {
            case branchesScroll:
                let pagenumber = Int(branchesScroll.contentOffset.x / branchesScroll.frame.size.width)
                pageControl.currentPage = pagenumber
            case trendingScroll:
                //54 es la suma de los margenes izq y derecho de cada cupon
                let pagenumber = Int((trendingScroll.contentOffset.x + 54) / trendingScroll.frame.size.width)
                trendingPageControl.currentPage = pagenumber
            case nearestScroll:
                //54 es la suma de los margenes izq y derecho de cada cupon
                let pagenumber = Int((nearestScroll.contentOffset.x + 54) / nearestScroll.frame.size.width)
                nearestPageControl.currentPage = pagenumber
            case toExpireScroll:
                //54 es la suma de los margenes izq y derecho de cada cupon
                let pagenumber = Int((toExpireScroll.contentOffset.x + 54) / toExpireScroll.frame.size.width)
                toExpirePageControl.currentPage = pagenumber
        default: break
        }
    }

    func getTopBranches() {
        branches = [Branch]()

        DashboardController.getDashboardBranchesWithSuccess(success:{(branchesData) -> Void in
            let json = JSON(data: branchesData)
            
            for (_, subJson): (String, JSON) in json["data"] {
                let branch_id = subJson["branch_id"].int
                let branch_name = subJson["name"].string
                let company_id = subJson["company_id"].int
                let banner = subJson["banner"].string
                
                
                let model = Branch(id: branch_id, name: branch_name, banner: banner, company_id: company_id)
                self.branches.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.reloadBranchCarousel()
                self.pageControl.numberOfPages = self.branches.count
                
                Utilities.fadeInFromBottomAnimation(self.branchesScroll, delay: 0, duration: 1, yPosition: 40)
                Utilities.fadeInFromBottomAnimation(self.pageControlContainer, delay:0.3, duration:0.3, yPosition: 10)
                
                if self.view.subviews.contains(self.mainLoader) {
                    self.mainLoader.removeFromSuperview()
                    Utilities.fadeInViewAnimation(self.trendingLoader, delay:0, duration:0.3)
                
                }
            });
        },
        failure: { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
              //self.view.addSubview(super.errorView)
              //self.errorView.translatesAutoresizingMaskIntoConstraints = false
            })
        })

    }
    func reloadBranchCarousel(){
        updater = CADisplayLink(target: self, selector: Selector("changePage"))
        updater!.frameInterval = 300
        updater!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        for (index, branch) in branches.enumerate() {
            
            let scrollWidth = branchesScroll.frame.size.width
            let scrollHeight = branchesScroll.frame.size.height
            let actualX = branchesScroll.frame.size.width * CGFloat(index)
            let margin:CGFloat = 20.0
            
            let branchNameLbl: UILabel = UILabel(frame: CGRectMake(margin+actualX, 80, scrollWidth-80, 75))
            branchNameLbl.alpha = 0
            branchNameLbl.textColor = UIColor.whiteColor()
            branchNameLbl.font = UIFont(name: "Montserrat-Regular", size: 26)
            branchNameLbl.text = branch.name.uppercaseString
            branchNameLbl.numberOfLines = 2
            branchNameLbl.layer.shadowOffset = CGSize(width: 3, height: 3)
            branchNameLbl.layer.shadowOpacity = 0.6
            branchNameLbl.layer.shadowRadius = 1
            
            
            let progressIcon = MMMaterialDesignSpinner(frame: CGRectMake(actualX + ((branchesScroll.frame.size.width / 2) - (30 / 2)), (branchesScroll.frame.size.height / 2) - (30 / 2), 30, 30))
            
            /*let progressIcon = UIActivityIndicatorView(frame: CGRectMake(actualX + ((branchesScroll.frame.size.width / 2) - (30 / 2)), (branchesScroll.frame.size.height / 2) - (30 / 2), 30, 30))
            progressIcon.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray*/
            
            progressIcon.lineWidth = 2.0
            progressIcon.tintColor = Utilities.dopColor
            progressIcon.startAnimating()
            
            
            
            let imageView: UIImageView = UIImageView(frame: CGRectMake(actualX, 0, scrollWidth, scrollHeight))
            imageView.alpha = 0
        
            let imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(branch.company_id!)/\(branch.banner!)")
            
            //let imageUrl = NSURL(string: "http://axeetech.com/wp-content/uploads/2014/09/458791.jpg")
            print("\(Utilities.dopImagesURL)\(branch.company_id!)/\(branch.banner!)")
            
            Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                if let image = data{
                    dispatch_async(dispatch_get_main_queue()) {
                        let imageData: NSData = NSData(data: image)
                        imageView.image = UIImage(data: imageData)
                        if imageView.image == nil { imageView.backgroundColor = Utilities.dopColor }
                        
                        Utilities.fadeInFromBottomAnimation(imageView, delay: 0, duration: 1, yPosition: 20)
                        Utilities.fadeInFromBottomAnimation(branchNameLbl, delay: 0.8, duration: 1, yPosition: 20)
                        Utilities.fadeOutToBottomWithCompletion(progressIcon, delay: 0, duration: 0.5, yPosition: 0, completion: { (value) -> Void in
                            progressIcon.removeFromSuperview()
                        })

                    }
                }else{
                    print("Error")
                }
            })

            
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.tag = branch.id
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "performSegueToBranch:"))
        
            branchesScroll.addSubview(imageView)
            branchesScroll.addSubview(branchNameLbl)
            branchesScroll.addSubview(progressIcon)
        }
    
        branchesScroll.contentSize = CGSizeMake(branchesScroll.frame.size.width*CGFloat(branches.count), branchesScroll.frame.size.height)
        pageControlContainer.layer.cornerRadius = 4
        pageControlContainer.layer.masksToBounds = true
    }
    
    func performSegueToBranch(sender: UIGestureRecognizer) {
        let view_controller = self.storyboard!.instantiateViewControllerWithIdentifier("BranchProfileStickyController") as! BranchProfileStickyController
        view_controller.branch_id = (sender.view?.tag)!
        self.navigationController?.pushViewController(view_controller, animated: true)
    }
    
    func changePage() {
        let width = branchesScroll.frame.size.width
        let page = branchesScroll.contentOffset.x + width

        if branchesScroll.contentSize.width <= page || firstCallToUpdater == true {
            branchesScroll.setContentOffset(CGPointMake(0, 0), animated: true)
        } else { branchesScroll.setContentOffset(CGPointMake(page, 0), animated: true) }

        if firstCallToUpdater { firstCallToUpdater = false }
    }

    func getTrendingCoupons() {
        
        trending = [Coupon]()
        trendingScroll.layer.masksToBounds = false
        trendingScroll.subviews.forEach({ $0.removeFromSuperview() })
        DashboardController.getTrendingCouponsWithSuccess(success: { (couponsData) -> Void in
            let json = JSON(data: couponsData)
            
                for (_, subJson): (String, JSON) in json["data"]{
                    let coupon_id = subJson["coupon_id"].int
                    let coupon_name = subJson["name"].string
                    let coupon_description = subJson["description"].string
                    let coupon_limit = subJson["limit"].string
                    let coupon_exp = "2015-09-30"
                    let coupon_logo = subJson["logo"].string
                    let branch_id = subJson["branch_id"].int
                    let company_id = subJson["company_id"].int
                    let total_likes = subJson["total_likes"].int
                    let user_like = subJson["user_like"].int
                    let latitude = subJson["latitude"].double!
                    let longitude = subJson["longitude"].double!
                    let banner = subJson["banner"].string ?? ""
//                    let categoryId = subJson["category_id"].int!
                    let available = subJson["available"].int!
                    let taken = subJson["taken"].bool!
                
                    let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: 1, available: available, taken: taken)
                
                    self.trending.append(model)
                }
            
                dispatch_async(dispatch_get_main_queue(), {
                    let margin = 18
                    let positionX = 18
                    let couponWidth = 180
                    
                    for (index, coupon) in self.trending.enumerate() {
                        let coupon_box: TrendingCoupon = NSBundle.mainBundle().loadNibNamed("TrendingCoupon", owner: self, options:
                        nil)[0] as! TrendingCoupon
        
                        var position = 0
                        position = positionX + ((margin + couponWidth) * index)
                        coupon_box.setCoupon(coupon, view: self, x: CGFloat(position), y: 0)

                        let imageUrl = NSURL(string: "\(Utilities.dopImagesURL)\(coupon.company_id)/\(coupon.logo)")
                        coupon_box.logo.alpha = 0
                        Utilities.downloadImage(imageUrl!, completion: {(data, error) -> Void in
                            if let image = data{
                                dispatch_async(dispatch_get_main_queue()) {
                                    let imageData: NSData = NSData(data: image)
                                    coupon_box.logo.image = UIImage(data: imageData)
                                    Utilities.fadeInViewAnimation(coupon_box.logo, delay:0, duration:1)
                                }
                            }else{
                                print("Error")
                            }
                        })
                        
                        coupon_box.loadItem(coupon, viewController: self)
                        Utilities.applyPlainShadow(coupon_box)
                        self.trendingScroll.addSubview(coupon_box)
                        coupon_box.tag = index
                    }
                    
                    let trendingScroll_size = ((margin+couponWidth)*self.trending.count)+margin
                    self.trendingPageControl.numberOfPages = self.trending.count/2
                    self.trendingScroll.contentSize = CGSizeMake(CGFloat(trendingScroll_size), self.trendingScroll.frame.size.height)
                    Utilities.fadeInFromBottomAnimation(self.trendingContainer, delay: 0, duration: 1, yPosition: 30)
                    if self.trendingLoader.alpha>0{
                        Utilities.fadeOutViewAnimation(self.trendingLoader, delay:0, duration:0.3)
                        self.trendingLoader.stopAnimating()

                    }
                    if self.view.subviews.contains(self.mainLoader) {
                        self.mainLoader.removeFromSuperview()
                    }
                });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                })
        })
        
    }
    
    func getToExpireCoupons() {
        almost_expired = [Coupon]()
        
        self.mainScroll.addSubview(toexpireLoader)

        toExpireScroll.subviews.forEach({ $0.removeFromSuperview() })

        DashboardController.getAlmostExpiredCouponsWithSuccess(success: { (couponsData) -> Void in
            let json = JSON(data: couponsData)
            
            for (_, subJson): (String, JSON) in json["data"]{
                let coupon_id = subJson["coupon_id"].int
                let coupon_name = subJson["name"].string
                let coupon_description = subJson["description"].string
                let coupon_limit = subJson["limit"].string
                let coupon_exp = "2015-09-30"
                let coupon_logo = subJson["logo"].string
                let branch_id = subJson["branch_id"].int
                let company_id = subJson["company_id"].int
                let total_likes = subJson["total_likes"].int
                let user_like = subJson["user_like"].int
                let latitude = subJson["latitude"].double!
                let longitude = subJson["longitude"].double!
                let banner = subJson["banner"].string ?? ""
                //                    let categoryId = subJson["category_id"].int!
                let available = subJson["available"].int!
                
                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: 1, available: available, taken: false)
                
                self.almost_expired.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let margin = 18
                let positionX = 18
                let couponWidth = 180
                
                for (index, coupon) in self.almost_expired.enumerate() {
                    let coupon_box: ToExpireCoupon = NSBundle.mainBundle().loadNibNamed("ToExpireCoupon", owner: self, options:
                        nil)[0] as! ToExpireCoupon
                    
                    var position = 0
                    position = positionX+((margin+couponWidth)*index)
                    coupon_box.move(CGFloat(position),y: 0)
                    coupon_box.descriptionLbl.text = coupon.couponDescription
                    coupon_box.branchNameLbl.text = coupon.name
                    coupon_box.branchNameLbl.sizeToFit()
                    coupon_box.loadItem(coupon, viewController: self)
                    coupon_box.tag = coupon.id
                
                    self.toExpireScroll.addSubview(coupon_box)
                }
                
                let trendingScroll_size = ((margin + couponWidth) * self.almost_expired.count) + margin
                self.toExpirePageControl.numberOfPages = self.almost_expired.count / 2
                self.toExpireScroll.contentSize = CGSizeMake(CGFloat(trendingScroll_size), self.toExpireScroll.frame.size.height)
                
                Utilities.fadeInFromBottomAnimation(self.toExpireContainer, delay:0, duration:1, yPosition: 20)
                
                Utilities.fadeOutViewAnimation(self.toexpireLoader, delay:0, duration:0.3)
                self.toexpireLoader.stopAnimating()
            });
            },
            
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    
                })
        })
    }
    
    func triggerCouponModal(sender: UIGestureRecognizer) {
        
    }
    
    func getNearestCoupons() {
        nearest = [Coupon]()
        nearestScroll.subviews.forEach({ $0.removeFromSuperview() })

        let latitude = User.coordinate.latitude
        let longitude = User.coordinate.longitude
        
        let params:[String:AnyObject] = [
            "latitude": latitude,
            "longitude": longitude,
            "radio": 15
        ]
        
        DashboardController.getNearestCoupons(params, success: {(branchesData) -> Void in
            let json = JSON(data: branchesData)
            for (_, subJson): (String, JSON) in json["data"]{
                let coupon_id = subJson["coupon_id"].int
                let coupon_name = subJson["name"].string
                let coupon_description = subJson["description"].string
                let coupon_limit = subJson["limit"].string
                let coupon_exp = "2015-09-30"
                let coupon_logo = subJson["logo"].string
                let branch_id = subJson["branch_id"].int
                let company_id = subJson["company_id"].int
                let total_likes = subJson["total_likes"].int
                let user_like = subJson["user_like"].int
                let latitude = subJson["latitude"].double!
                let longitude = subJson["longitude"].double!
                let banner = subJson["banner"].string ?? ""
                //                    let categoryId = subJson["category_id"].int!
                let available = subJson["available"].int!
                
                let model = Coupon(id: coupon_id, name: coupon_name, description: coupon_description, limit: coupon_limit, exp: coupon_exp, logo: coupon_logo, branch_id: branch_id, company_id: company_id,total_likes: total_likes, user_like: user_like, latitude: latitude, longitude: longitude, banner: banner, category_id: 1, available: available, taken: false)
                
                self.nearest.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let margin = 18
                let positionX = 18
                let couponWidth = 180
                
                for (index, coupon) in self.nearest.enumerate() {
                    let coupon_box:NearestCoupon = NSBundle.mainBundle().loadNibNamed("NearestCoupon", owner: self, options:
                        nil)[0] as! NearestCoupon
                    
                    var position = 0
                    position = positionX+((margin + couponWidth) * index)
                    coupon_box.move(CGFloat(position),y: 0)
                    coupon_box.descriptionLbl.text = coupon.couponDescription
                    coupon_box.branchNameLbl.text = coupon.name
                    coupon_box.branchNameLbl.sizeToFit()
                    coupon_box.loadItem(coupon, viewController: self)
                    
                    self.nearestScroll.addSubview(coupon_box);
                }
                
                let trendingScroll_size = ((margin+couponWidth)*self.nearest.count) + margin
                self.nearestPageControl.numberOfPages = self.nearest.count / 2
                self.nearestScroll.contentSize = CGSizeMake(CGFloat(trendingScroll_size), self.nearestScroll.frame.size.height)
                
                Utilities.fadeInFromBottomAnimation(self.nearestContainer, delay:0, duration:1, yPosition: 20)
               
                Utilities.fadeOutViewAnimation(self.nearestLoader, delay:0, duration:0.3)
                self.nearestLoader.stopAnimating()

            });

            },
            failure:{(branchesData)-> Void in
        })
    }
 
    
    
    func takeCoupon(coupon_id:Int) {
        
        let latitude = String(stringInterpolationSegment:locValue!.latitude)
        let longitude = String(stringInterpolationSegment: locValue!.longitude)

        let params:[String: AnyObject] = [
            "coupon_id" : coupon_id,
            "taken_date" : "2015-01-01",
            "latitude" : latitude,
            "longitude" : longitude ]

        CouponController.takeCouponWithSuccess(params,
        success:{(couponsData) -> Void in
            let json = JSON(data: couponsData)
        },
        failure: { (error) -> Void in
            
        })
        
    
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = manager.location!.coordinate
        User.coordinate = locationManager.location!.coordinate
        locationManager.stopUpdatingLocation()
        
        if !obtained_location {
            getNearestCoupons()
            obtained_location = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            let i = sender!.tag
        
            let model = self.trending[i]
            if segue.identifier == "couponDetail" {
                let coupon_box: TrendingCoupon = sender as! TrendingCoupon
                let view = segue.destinationViewController as! CouponDetailViewController
                view.couponsName = model.name
                view.couponsDescription = model.couponDescription
                view.location = model.location
                view.branchId = model.branch_id
                view.couponId = model.id
                view.logo = coupon_box.logo.image
                view.banner = model.banner
                view.companyId = model.company_id
                view.categoryId = model.categoryId
            }
        
    }
    
    @IBAction func goToPage(sender: AnyObject) {
        let page = branchesScroll.frame.size.width * CGFloat(pageControl.currentPage)
        branchesScroll.setContentOffset(CGPointMake(page, 0), animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        if (updater) != nil {
            updater!.paused = true
            branchesScroll.setContentOffset(CGPointMake(0, 0), animated: false)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
