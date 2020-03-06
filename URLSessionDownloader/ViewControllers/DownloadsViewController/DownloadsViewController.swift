//
//  DownloadsViewController.swift
//  URLSessionDownloader
//
//  Created by Oleh Mykytyn on 04.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import Foundation
import UIKit

private enum Constants {
    static let heightForRow: Int = 100
}

final class DownloadsViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var downloadsTableView: UITableView!
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    
    // MARK: Properties
    
    var downloadService: DownloadService = DownloadService()
    lazy var downloadsSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    var images: [Image] = [
        Image(url: URL(string: "https://unsplash.com/photos/4rG9L89HnDU/download")!),
        Image(url: URL(string: "https://unsplash.com/photos/xDU1mH2Ec_E/download")!),
        Image(url: URL(string: "https://unsplash.com/photos/5pYOmALZgtM/download")!),
        Image(url: URL(string: "https://unsplash.com/photos/lYXpVfgb02E/download")!)
    ]
    lazy var imagesToShow = images
    
    // MARK: IBActions

    @IBAction func segmentControlChanged(_ sender: Any) {
        reloadImagesToShow()
        downloadsTableView.reloadData()
    }
    
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
        reloadImagesToShow()
        downloadsTableView.reloadData()
    }
    
    // MARK: Private methods
    
    private func reloadImagesToShow() {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            imagesToShow = images.filter { (image) -> Bool in
                downloadService.downloads[image.url]?.state == .notStarted
            }
        case 1:
            imagesToShow = images.filter { (image) -> Bool in
                downloadService.downloads[image.url]?.state == .inProgress ||
                downloadService.downloads[image.url]?.state == .paused
            }
        case 2:
            imagesToShow = images.filter { (image) -> Bool in
                downloadService.downloads[image.url]?.state == .finished
            }
        default:
            print("Error: not implemented default case when segmentControl changed")
        }
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
        return CGFloat(Constants.heightForRow)
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
                print("started tapped")
            case .inProgress:
                downloadService.pause(image)
                print("paused tapped")
            case .paused:
                downloadService.resume(image)
                print("resumed tapped")
            case .finished:
                print("finished tapped")
            case .canceled:
                print("Error: .cancelled not implemented")
            case .none:
                print("Error: .none case not implemented")
            }
            
            cell.configure(image: image, download: download)
        }
        reloadImagesToShow()
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
            //            print("Downloaded image url:", sourceURL)
        }catch let error{
            print("Error: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.reloadImagesToShow()
            self.downloadsTableView.reloadData()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("Resuming with offset: \(fileOffset) bytes")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url,
              let download = downloadService.downloads[url] else { return }
        
        // progress in percentage
        let progress =  Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        download.progress = progress

        print("progress: \(totalBytesWritten) / \(totalBytesExpectedToWrite) bytes")
    }
    
    //    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    //        print("Error of completion: \(error)")
    //        print("Progress: \((task as! URLSessionDownloadTask).progress)")
    //    }
}

//extension DownloadsViewController: URLSessionDataDelegate {
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        print("data received: \(data)")
//    }
//}

