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
    static let heightForRow: Int = 85
}

final class DownloadsViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var downloadsTableView: UITableView!
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    
    // MARK: Properties
    
    var downloadService: DownloadService = DownloadService()
    lazy var downloadsSession: URLSession = URLSession(configuration: .background(withIdentifier: "bgsession"), delegate: self, delegateQueue: nil)
    
    // TODO: download json from api
    var images: [Image] = []
    lazy var imagesToShow = images
    
    // MARK: IBActions
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        reloadImagesToShow()
        downloadsTableView.reloadData()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkManager.shared.fetchImages { (data, resp, err) in
            guard let data = data else { return }
            do {
                let parsedImage = try JSONDecoder().decode(ImageResponse.self, from: data )
                print(parsedImage)
//                self.images.append(parsedImage)
            } catch {
                print("Error while json serialization")
            }
        }
        // TODO: use this to set "No internet connection" to the view
        if Reachability.isConnectedToNetwork() {
            print("Internet Connection Available!")
        } else{
            print("Internet Connection not Available!")
        }
        
        //        print("app started")
        //
        //        setupDownloadsTableView()
        //        setupDownloadTableViewCell()
        //        setupSegmentControl()
        //
        //        downloadService.downloadsSession = downloadsSession
        //
        //        // code below is just for testing
        //        for image in imagesToShow {
        //            downloadService.add(image)
        //        }
        //        reloadImagesToShow()
        //        downloadsTableView.reloadData()
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
    
    //swiftlint:disable force_cast
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadTableViewCell", for: indexPath) as! DownloadTableViewCell
        cell.delegate = self
        
        let image = imagesToShow[indexPath.row]
        cell.configure(download: downloadService.downloads[image.url])
        
        return cell
    }
    //swiftlint:enable force_cast
}

// MARK: UITableViewDelegate

extension DownloadsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Constants.heightForRow)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteFromToDo = UIContextualAction(style: .destructive, title: nil) { (_, _, _: (Bool) -> Void) in
            let image = self.imagesToShow[indexPath.row]
            self.downloadService.cancel(image)
            self.downloadService.downloads[image.url]?.state = .notStarted
            // TODO: clear cache here
            self.reloadImagesToShow()
            self.downloadsTableView.reloadData()
        }
        let deleteFromDone = UIContextualAction(style: .destructive, title: nil) { (_, _, _: (Bool) -> Void) in
            let image = self.imagesToShow[indexPath.row]
            self.downloadService.downloads[image.url]?.state = .notStarted
            // TODO: clear image here
            self.reloadImagesToShow()
            self.downloadsTableView.reloadData()
        }
        // TODO: action for 5.1
        deleteFromToDo.backgroundColor = .red
        deleteFromToDo.image = .remove
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            return nil
        case 1:
            return UISwipeActionsConfiguration(actions: [deleteFromToDo])
        case 2:
            return UISwipeActionsConfiguration(actions: [deleteFromDone])
        default:
            return nil
        }
    }
}

// MARK: DownloadTableViewCellDelegate

extension DownloadsViewController: DownloadTableViewCellDelegate {
    func buttonTapped(_ cell: DownloadTableViewCell) {
        guard let indexPath = downloadsTableView.indexPath(for: cell) else { return }
        let image = imagesToShow[indexPath.row]
        guard let download = downloadService.downloads[image.url] else { return }
        
        switch download.state {
        case .notStarted:
            downloadService.resume(download.image)
            print("started tapped")
        case .inProgress:
            downloadService.pause(download.image)
            print("paused tapped")
        case .paused:
            downloadService.resume(download.image)
            print("resumed tapped")
        case .finished:
            print("finished tapped")
        case .canceled:
            print("Error: .cancelled not implemented")
        }
        
        cell.configure(download: download)
        reloadImagesToShow()
        downloadsTableView.reloadData()
    }
}

// MARK: URLSessionDownloadDelegate

extension DownloadsViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        
        let download = downloadService.downloads[sourceURL]
        download?.state = .finished
        download?.task = nil
        print("Download Completed!")
        do {
            let data = try Data(contentsOf: location)
            let img = UIImage(data: data)
            
            download?.image.downloaded = true
            
            print("Downloaded image: \(img)")
            print("Downloaded image url: \(sourceURL)\n")
        } catch let error {
            print("Error while converting contents of location to data: \(error.localizedDescription)")
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
        
        DispatchQueue.main.async {
            if let cell = self.downloadsTableView.cellForRow(at: IndexPath(row: download.image.index, section: 0)) as? DownloadTableViewCell {
                cell.updateProgressView(progress: download.progress)
            }
        }
    }
    
    //    swiftlint:disable force_cast
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Error of completion: \(error)")
        print("Progress: \((task as! URLSessionDownloadTask).progress)")
    }
    //    swiftlint:enable force_cast
}
