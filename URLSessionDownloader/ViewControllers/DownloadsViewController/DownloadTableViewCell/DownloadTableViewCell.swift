//
//  DownloadTableViewCell.swift
//  URLSessionDownloader
//
//  Created by Oleh Mykytyn on 04.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import UIKit

protocol DownloadTableViewCellDelegate {
    func buttonTapped(_ cell: DownloadTableViewCell)
}

class DownloadTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var button: UIButton!
    
    // MARK: Properties
    
    var delegate: DownloadTableViewCellDelegate?
    
    // MARK: IBActions
    
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.buttonTapped(self)
    }
    
    // MARK: Methods
    
    func configure(image: Image, download: Download?) {
        name.text = image.url.absoluteString
        
        switch download?.state {
        case .notStarted:
            button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        case .inProgress:
            button.setImage(UIImage(systemName: "stop.circle"), for: .normal)
        case .paused:
            button.setImage(UIImage(systemName: "play.circle"), for: .normal)
        case .finished:
            button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        case .canceled:
            print("Warning: cancelled not implemented")
        case .none:
            return
        }
    }
}
