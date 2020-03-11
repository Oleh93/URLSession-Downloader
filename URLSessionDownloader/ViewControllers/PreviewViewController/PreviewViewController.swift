//
//  PreviewViewController.swift
//  URLSessionDownloader
//
//  Created by Олег on 10.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import UIKit

final class PreviewViewController: UIViewController {
    
    var imageView: UIImageView = UIImageView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageView()
    }
    
    func addImageView(image: UIImage) {
        imageView.image = image
        view.insertSubview(imageView, at: 0) /*For put image view below all image*/
    }
    
    private func setupImageView() {
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        imageView.contentMode = .scaleAspectFill
    }
}
