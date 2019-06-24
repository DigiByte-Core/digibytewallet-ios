//
//  SupportViewController.swift
//  breadwallet
//
//  Created by John Gabelmann on 1/11/18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit

class SupportViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.presentingViewController?.viewWillAppear(false)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let c = closeButton {
            c.setImage(#imageLiteral(resourceName: "Close").withRenderingMode(.alwaysTemplate), for: .normal)
            c.tintColor = .white
            c.setTitle("", for: .normal)
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
