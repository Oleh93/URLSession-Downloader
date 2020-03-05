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
    lazy var downloadsSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    var images: [Image] = [
        Image(url: URL(string: "https://images.unsplash.com/photo-1581704914273-a69d2c4b8b1c?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjExODcwMn0")!),
        Image(url: URL(string: "https://images.unsplash.com/photo-1580871104805-2ef468b129b9?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjExODcwMn0")!),
        Image(url: URL(string: "https://images.unsplash.com/photo-1582972546430-8bd7a9d14ccb?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjExODcwMn0")!),
        Image(url: URL(string: "https://images.unsplash.com/photo-1581516901321-5234a2de60ef?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjExODcwMn0")!)
    ]
    lazy var imagesToShow = images
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("app started")
        
        setupDownloadsTableView()
        setupDownloadTableViewCell()
        setupSegmentControl()
        
        downloadService.downloadsSession = downloadsSession

        // code below is just for testing
        for image in imagesToShow {
            downloadService.add(image)
        }
        downloadsTableView.reloadData()
    }
    
    // MARK: Private methods
    @objc private func segmentControlChanged() {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            imagesToShow = images.filter { (image) -> Bool in
                downloadService.downloads[image.url]?.state == .notStarted
            }
        case 1:
            imagesToShow = images.filter { (image) -> Bool in
                downloadService.downloads[image.url]?.state == .inProgress
            }
        case 2:
            imagesToShow = images.filter { (image) -> Bool in
                downloadService.downloads[image.url]?.state == .finished
            }
        default:
            print("Error: default case when segmentControl changed")
        }

        downloadsTableView.reloadData()
    }
    
    private func setupDownloadTableViewCell() {
        let nib = UINib.init(nibName: "DownloadTableViewCell", bundle: nil)
        self.downloadsTableView.register(nib, forCellReuseIdentifier: "DownloadTableViewCell")
    }
    
    private func setupDownloadsTableView() {
        downloadsTableView.delegate = self
        downloadsTableView.dataSource = self
    }
    
    private func setupSegmentControl() {
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentControlChanged), for: .valueChanged)
    }
}

// MARK: UITableViewDataSource
extension DownloadsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadTableViewCell", for: indexPath) as! DownloadTableViewCell
        cell.delegate = self
        
        let image = imagesToShow[indexPath.row]
        cell.configure(image: image, download: downloadService.downloads[image.url])
        
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
    func buttonTapped(_ cell: DownloadTableViewCell) {
        if let indexPath = downloadsTableView.indexPath(for: cell) {
            let image = imagesToShow[indexPath.row]
            let download = downloadService.downloads[image.url]
            
            switch download?.state {
            case .notStarted:
                downloadService.resume(image)
                print("started")
            case .inProgress:
                downloadService.pause(image)
                print("paused")
            case .paused:
                downloadService.resume(image)
                print("resumed")
            case .finished:
                print("finished")
            case .canceled:
                print("Error: .cancelled not implemented")
            case .none:
                print("Error: .none case not implemented")
            }

            cell.configure(image: image, download: download)
        }

        downloadsTableView.reloadData()
    }
}

// MARK: URLSessionDownloadDelegate
extension DownloadsViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        
        let download = downloadService.downloads[sourceURL]

        downloadService.downloads[sourceURL]?.state = .finished
        
        print("Download Completed!")
        do {
            let data = try Data(contentsOf: location)
            download?.image.downloaded = true
            print("Downloaded image url:", sourceURL)
        }catch let error{
            print("Error: \(error.localizedDescription)")
        }

        DispatchQueue.main.async {
            self.downloadsTableView.reloadData()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("we are here")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Error of completion \(error)")
        print((task as! URLSessionDownloadTask).progress)
    }
    
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        guard let url = downloadTask.originalRequest?.url,
//        let download = downloadService.downloads[url] else { return }
//
//        let progress =  Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
//        download.progress = progress
//        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
//
////        print(String(format: "%.1f%% of %@", progress * 100, totalSize))
//    }
}

