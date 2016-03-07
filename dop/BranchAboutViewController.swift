//
//  BranchAboutViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 1/19/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit
import MapKit

protocol AboutPageDelegate {
    func resizeAboutView(dynamic_height: CGFloat)
    func setFollow(branch: Branch)
}

class BranchAboutViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var delegate: AboutPageDelegate?
    
    @IBOutlet weak var branch_location_map: MKMapView!
    @IBOutlet weak var branch_description: UITextView!
    @IBOutlet weak var pin_icon: UIImageView!
    @IBOutlet weak var clock_icon: UIImageView!
    
    var parent_view: BranchProfileStickyController!
    var branch_pin: CLLocation!
    let regions_radius: CLLocationDistance = 500
    
    override func viewDidLoad() {
//        branch_description.text = description
        pin_icon.image = pin_icon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        pin_icon.tintColor = UIColor.lightGrayColor()
        clock_icon.image = clock_icon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        clock_icon.tintColor = UIColor.lightGrayColor()
        
        self.branch_location_map.delegate = self
        self.view.frame.size.width = UIScreen.mainScreen().bounds.width
        self.view.frame.size.height = 350
        getBranchProfile()
        
        if self.branch_location_map != nil {
            let tap = UITapGestureRecognizer(target: self, action: Selector("pressMap:"))
            self.branch_location_map.addGestureRecognizer(tap)
        }

    }
    
    
//    override func viewWillAppear(animated: Bool) {
//        delegate?.resizeAboutView!(330)
//    }
//    
    override func viewDidAppear(animated: Bool) {
        parent_view.view.setNeedsLayout()
    }
    
    func setFrame() {
        let dynamic_height: CGFloat = 330
        delegate?.resizeAboutView(dynamic_height)

    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinate_region = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regions_radius * 2.0, regions_radius * 2.0)
        branch_location_map.setRegion(coordinate_region, animated: false)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        let reuse_id = "custom"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuse_id)
        if mapView.userLocation == annotation as! NSObject { return nil }
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuse_id)
            annotationView!.canShowCallout = true
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let customAnnotation = annotation as! Annotation
        annotationView!.image = UIImage(named: customAnnotation.typeOfAnnotation)
        
        return annotationView
    }

    
    func getBranchProfile() {
        BranchProfileController.getBranchProfileWithSuccess(parent_view.branch_id, success: { (data) -> Void in
            let data = JSON(data: data)
            var json = data["data"]
            print(json)
            json = json[0]
            let branch_id = json["branch_id"].int!
            let latitude = json["latitude"].double
            let longitude = json["longitude"].double
            let following = json["following"].bool!
            let branch_name = json["name"].string
            let company_id = json["company_id"].int
            let banner = json["banner"].string
            let logo = json["logo"].string!
            
            
            let model = Branch(id: branch_id, name: branch_name, banner: banner, company_id: company_id, logo: logo, following: following)
            
            
            self.branch_pin = CLLocation(latitude: latitude!, longitude: longitude!)
            let new_location = CLLocationCoordinate2DMake(latitude!, longitude!)
            self.centerMapOnLocation(self.branch_pin)
            
            dispatch_async(dispatch_get_main_queue(), {
                let drop_pin = Annotation(coordinate: new_location, title: json["name"].string!, subTitle: "nada", branch_distance: "4.3", branch_id: branch_id, company_id: 0, logo: "")
                
                switch json["category_id"].int! {
                    case 1: drop_pin.typeOfAnnotation = "marker-food-icon"
                    case 2: drop_pin.typeOfAnnotation = "marker-services-icon"
                    case 3: drop_pin.typeOfAnnotation = "marker-entertainment-icon"
                default: break
                }
                
                self.branch_location_map.addAnnotation(drop_pin)
                Utilities.fadeInFromBottomAnimation(self.view, delay: 0, duration: 1, yPosition: 20)

                self.delegate!.setFollow(model)
            })
            
            },
            failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    print(error)
                })
        })
    }
    
    func reloadWithOffset(parent_scroll: UICollectionView) {
        parent_scroll.finishInfiniteScroll()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.frame.size.width = UIScreen.mainScreen().bounds.width
    }
    
    func pressMap(sender: UITapGestureRecognizer){
        //If Google Maps is installed...
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let googleMaps = UIAlertAction(title: "Google Maps", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.openGoogleMaps()
            })
            let appleMaps = UIAlertAction(title: "Apple Maps", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.openAppleMaps()
            })
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(googleMaps)
            optionMenu.addAction(appleMaps)
            optionMenu.addAction(cancelAction)
            
            self.presentViewController(optionMenu, animated: true, completion: nil)
        } else {
            self.openAppleMaps()
        }
    }
    
    func openGoogleMaps(){
        let customURL = "comgooglemaps://?daddr=\(self.branch_pin!.coordinate.latitude),\(self.branch_pin!.coordinate.longitude)&directionsmode=driving"
        
        UIApplication.sharedApplication().openURL(NSURL(string: customURL)!)
    }
    
    func openAppleMaps() {
        
        let latitute:CLLocationDegrees =  (self.branch_pin!.coordinate.latitude)
        let longitute:CLLocationDegrees =  (self.branch_pin!.coordinate.longitude)
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        //mapItem.name = "\(self.coupon!.name)"
        mapItem.openInMapsWithLaunchOptions(options)
    }
}
