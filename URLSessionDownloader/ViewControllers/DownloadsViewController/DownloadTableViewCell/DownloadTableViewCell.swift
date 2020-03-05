//
//  DownloadTableViewCell.swift
//  URLSessionDownloader
//
//  Created by Oleh Mykytyn on 04.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import UIKit

protocol DownloadTableViewCellDelegate {
  func cancelTapped(_ cell: DownloadTableViewCell)
  func downloadTapped(_ cell: DownloadTableViewCell)
  func pauseTapped(_ cell: DownloadTableViewCell)
  func resumeTapped(_ cell: DownloadTableViewCell)
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
    @IBAction func btnTapped(_ sender: Any) {
        // TODO: call appropriate methods of DownloadTableViewCellDelegate
    }
}
