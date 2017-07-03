//
//  PageTwoViewController.swift
//  dop
//
//  Created by Edgar Allan Glez on 12/10/16.
//  Copyright © 2016 Edgar Allan Glez. All rights reserved.
//

import UIKit
import AVFoundation

class PageTwoViewController: UIViewController {
    @IBOutlet var tutorial_description: UILabel!
    @IBOutlet var tutorial_title: UILabel!
    @IBOutlet var top_logo: UIImageView!

    @IBOutlet weak var permission_button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyPlainShadow(permission_button)
        // Do any additional setup after loading the view.
        permission_button.alpha = 0
        
        top_logo.alpha = 0
        tutorial_title.alpha = 0
        tutorial_description.alpha = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func askPermission(_ sender: UIButton) {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied ||
            AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized {
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
            
        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo,
                                          completionHandler: { granted in
                                            if granted {
                                                DispatchQueue.main.async {
//                                                    self.giverView.alpha = 0
//                                                    self.setCameraConfig()
                                                    
//                                                    Utilities.permanentBounce(self.qr_image, delay: 0.5, duration: 0.8)
//                                                    Utilities.fadeInFromTopAnimation(self.qr_instructions_view, delay: 0, duration: 1, yPosition: 15)
                                                    self.view.layoutIfNeeded()
                                                }
                                            } else {
                                                DispatchQueue.main.async {
                                                    sender.setTitle("😭 NO, CORAL", for: UIControlState.normal)
                                                }
                                            }
            }
            )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Utilities.fadeInFromBottomAnimation(top_logo, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(tutorial_title, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(tutorial_description, delay: 0.5, duration: 1, yPosition: 20)
        Utilities.fadeInFromBottomAnimation(permission_button, delay: 0.8, duration: 1, yPosition: 20)
    }
    override func viewDidDisappear(_ animated: Bool) {
        top_logo.alpha = 0
        tutorial_title.alpha = 0
        tutorial_description.alpha = 0
        permission_button.alpha = 0
    }
}
