//
//  PopVC.swift
//  pixel-city
//
//  Created by Pavan Kumar N on 24/01/2019.
//  Copyright © 2019 Pavan Kumar N. All rights reserved.
//

import UIKit

class PopVC: UIViewController {

    @IBOutlet weak var popImage: UIImageView!
    var passedImage:UIImage!
    
    func initData(forImage image: UIImage){
        self.passedImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImage.image = passedImage
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func doubleTap(_ tap: UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }
}
