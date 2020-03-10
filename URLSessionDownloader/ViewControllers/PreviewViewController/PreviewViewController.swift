//
//  PreviewViewController.swift
//  URLSessionDownloader
//
//  Created by Олег on 10.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    var imageView:UIImageView = UIImageView.init()

    override func viewDidLoad() {
         super.viewDidLoad()
     }
     override func viewWillAppear(_ animated: Bool) {
     //self.view.bringSubview(toFront: imageView) //To bring imageview infront of other views put this method as per your requirement
     }
    func addImageView(image: UIImage)
    {
     imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
     //view.addSubview(imageView)
     view.insertSubview(imageView, at: 0) /*For put image view below all image*/
    }

}
