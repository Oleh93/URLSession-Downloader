//
//  DownloadsViewController.swift
//  URLSessionDownloader
//
//  Created by Oleh Mykytyn on 04.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import Foundation
import UIKit

class DownloadsViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet private weak var downloadsTableView: UITableView!
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    
    // MARK: Properties
    var downloadService: DownloadService = DownloadService()
    var downloadsSession: URLSession = URLSession(configuration: .default, delegate: DownloadsViewController(), delegateQueue: nil)
    var images: [Image] = []
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("started")
        
        setupDownloadsTableView()
        setupDownloadTableViewCell()
        
        downloadService.downloadsSession = downloadsSession
        
        // code below is just for testing
        let image = Image(url: URL(string: "https://images.unsplash.com/photo-1581704914273-a69d2c4b8b1c?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjExODcwMn0")!)
        downloadService.start(image)
//        downloadService.pause(image)
//        downloadService.resume(image)
        
    }
    
    // MARK: Private methods
    private func setupDownloadTableViewCell() {
        let nib = UINib.init(nibName: "DownloadTableViewCell", bundle: nil)
        self.downloadsTableView.register(nib, forCellReuseIdentifier: "DownloadTableViewCell")
    }
    
    private func setupDownloadsTableView() {
        downloadsTableView.delegate = self
        downloadsTableView.dataSource = self
    }
}

// MARK: UITableViewDataSource
extension DownloadsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadTableViewCell", for: indexPath) as! DownloadTableViewCell
        
        let img = images[indexPath.row]
        guard let download = downloadService.activeDownloads[img.url] else {return cell}
        let title = download.isDownloading ? "down" : "paused"
        cell.name.text = title
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension DownloadsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: DownloadTableViewCellDelegate
extension DownloadsViewController: DownloadTableViewCellDelegate {
    
    func cancelTapped(_ cell: DownloadTableViewCell) {
        if let indexPath = downloadsTableView.indexPath(for: cell) {
            let image = images[indexPath.row]
            downloadService.cancel(image)
        }
    }
    
    func downloadTapped(_ cell: DownloadTableViewCell) {
        if let indexPath = downloadsTableView.indexPath(for: cell) {
            let image = images[indexPath.row]
            downloadService.start(image)
        }
    }
    
    func pauseTapped(_ cell: DownloadTableViewCell) {
        if let indexPath = downloadsTableView.indexPath(for: cell) {
            let image = images[indexPath.row]
            downloadService.pause(image)
        }
    }
    
    func resumeTapped(_ cell: DownloadTableViewCell) {
        if let indexPath = downloadsTableView.indexPath(for: cell) {
            let image = images[indexPath.row]
            downloadService.resume(image)
        }
    }
}

// MARK: URLSessionDownloadDelegate
extension DownloadsViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else {
            return
        }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        
        print("Download Completed!")
        do {
            let data = try Data(contentsOf: location)
            let img = UIImage(data: data)
            download?.image.downloaded = true
            print("Downloaded image size:", img?.size.height, img?.size.width)
        }catch let error{
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url,
              let download = downloadService.activeDownloads[url] else { return }
        
        let progress =  Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        download.progress = progress
        print("progress:", progress)
    }
}

extension DownloadsViewController: URLSessionDelegate {
    // MARK: TODO: write URLSessionDelegate methods
}
