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

    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    // MARK: Properties
    
    var delegate: DownloadTableViewCellDelegate?
    
    // MARK: IBActions

    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.buttonTapped(self)
    }
    
    // MARK: Methods
    
    func updateProgressView(progress: Float) {
        progressView.progress = progress
    }
    
    func configure(download: Download?) {
        let image = download?.image
        
        if let description = image?.alt_description {
            name.text = description
        } else {
            name.text = image?.links.download.absoluteString
        }
        if let thumb = download?.image.urls.thumb {
            do {
                let data = try Data(contentsOf: thumb)
                self.icon?.image = UIImage(data: data)
            }catch {
                print("error")
            }
            
        }
        
        progressView.progress = download?.progress ?? 0
        switch download?.state {
        case .notStarted:
            button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
            self.progressView.isHidden = true
        case .inProgress:
            button.setImage(UIImage(systemName: "stop.circle"), for: .normal)
            self.progressView.isHidden = false
        case .paused:
            button.setImage(UIImage(systemName: "play.circle"), for: .normal)
            self.progressView.isHidden = false
        case .finished:
            button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            self.progressView.isHidden = true
        case .none:
            return
        }
    }
}
