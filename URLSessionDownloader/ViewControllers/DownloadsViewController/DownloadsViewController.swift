//
//  DownloadsViewController.swift
//  URLSessionDownloader
//
//  Created by Oleh Mykytyn on 04.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import Foundation
import UIKit
import Network

private enum Constants {
    static let heightForRow: Int = 85
}

final class DownloadsViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var downloadsTableView: UITableView!
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var label: UILabel!    
    // MARK: Properties
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var downloadService: DownloadService = DownloadService()

    lazy var downloadsSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "MySession")
        config.sessionSendsLaunchEvents = true
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    var images: [ImageResponse] = []
    
    lazy var imagesToShow = images
    
    // MARK: IBActions
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        reloadImagesToShow()
        downloadsTableView.reloadData()
    }
    
    func checkConnection() {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.startDownloading()
                }
            } else {
                print("No connection.")
                DispatchQueue.main.sync {
                    self.downloadsTableView.isHidden = true
                    self.segmentControl.isHidden = true
                    self.label.isHidden = false
                    self.label.text = "No internet connection"
                }
            }

            print(path.isExpensive)
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkConnection()
    }
    
    // MARK: Private methods
    
    private func startDownloading() {
        self.downloadsTableView.isHidden = true
        self.segmentControl.isHidden = true
        label.text = "Fetching data..."

        setupSegmentControl()
        downloadService.downloadsSession = downloadsSession
        
        NetworkManager.shared.fetchImages { (data, _, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.label.text = "No data To Do"
                }
                return
            }
            guard let data = data else { return }
            do {
                let parsedImages = try JSONDecoder().decode([ImageResponse].self, from: data)
                self.images = parsedImages
                DispatchQueue.main.async {
                    self.label.isHidden = true
                    self.downloadsTableView.isHidden = false
                    self.segmentControl.isHidden = false
                    
                    for i in self.images { self.downloadService.add(i) }
                    
                    self.reloadImagesToShow()
                    self.downloadsTableView.reloadData()
                }
            } catch {
                print("Error while json serialization")
            }
        }
    }
    
    private func reloadImagesToShow() {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            imagesToShow = images.filter { (image) -> Bool in
                return downloadService.downloads[image.links.download]?.state == .notStarted
            }
        case 1:
            imagesToShow = images.filter { (image) -> Bool in
                return downloadService.downloads[image.links.download]?.state == .inProgress ||
                    downloadService.downloads[image.links.download]?.state == .paused
            }
        case 2:
            imagesToShow = images.filter { (image) -> Bool in
                return downloadService.downloads[image.links.download]?.state == .finished
            }
        default:
            print("Error: not implemented default case when segmentControl changed")
        }
    }
    
    private func setupSegmentControl() {
        segmentControl.selectedSegmentIndex = 0
    }
    
    private func showImage(_ imageResponse: ImageResponse) {
        DispatchQueue.main.async {
            do {
                print(imageResponse.links.download.lastPathComponent)
                let data = try Data(contentsOf: self.documentsPath.appendingPathComponent(imageResponse.links.download.lastPathComponent + (imageResponse.id ?? "1")))
                let image = UIImage(data: data)
                if let image = image {
                    let vc = PreviewViewController(nibName: nil, bundle: nil)
                    vc.addImageView(image: image)
                    self.present(vc, animated: true)
                }
            } catch {
                print("error")
            }
        }
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
        cell.configure(download: downloadService.downloads[(image.links.download)])
        
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
        let deleteFromToDo = UIContextualAction(style: .destructive, title: "Cancel") { (_, _, _: (Bool) -> Void) in
            let image = self.imagesToShow[indexPath.row]
            self.downloadService.cancel(image)
            self.reloadImagesToShow()
            self.downloadsTableView.reloadData()
        }
        
        let deleteFromDone = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _: (Bool) -> Void) in
            let image = self.imagesToShow[indexPath.row]
            self.downloadService.cancel(image)
            let destinationURL = self.documentsPath.appendingPathComponent(image.links.download.lastPathComponent + (image.id ?? "1"))
            let fileManager = FileManager.default
            try? fileManager.removeItem(at: destinationURL)
            self.reloadImagesToShow()
            self.downloadsTableView.reloadData()
        }
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageResponse = imagesToShow[indexPath.row]
        showImage(imageResponse)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: DownloadTableViewCellDelegate

extension DownloadsViewController: DownloadTableViewCellDelegate {
    func buttonTapped(_ cell: DownloadTableViewCell) {
        guard let indexPath = downloadsTableView.indexPath(for: cell) else { return }
        let image = imagesToShow[indexPath.row]
        guard let download = downloadService.downloads[image.links.download] else { return }
        
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
        
        let destinationURL = documentsPath.appendingPathComponent(sourceURL.lastPathComponent + (download?.image.id ?? "1"))
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            print(location)
            try fileManager.moveItem(at: location, to: destinationURL)
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
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
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        download.progress = progress
        print("progress: \(totalBytesWritten) / \(totalBytesExpectedToWrite) bytes")
        
        DispatchQueue.main.async {
            guard let row = self.imagesToShow.firstIndex(where: { (img) -> Bool in
                img.id == download.image.id
            }) else { return }
            if let cell = self.downloadsTableView.cellForRow(at: IndexPath(row: row, section: 0)) as? DownloadTableViewCell {
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
