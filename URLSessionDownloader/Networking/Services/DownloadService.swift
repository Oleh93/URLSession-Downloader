//
//  DownloadService.swift
//  URLSessionDownloader
//
//  Created by Oleh Mykytyn on 04.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import Foundation

class DownloadService {
    var downloads: [URL: Download] = [ : ]
    var downloadsSession: URLSession!
    
    func cancel(_ image: ImageResponse) {
        guard let download = downloads[image.links.download] else { return }
        
        download.task?.cancel()
        download.resumeData = nil
        download.state = .notStarted
    }
    
    func pause(_ image: ImageResponse) {
        guard let download = downloads[image.links.download] else { return }
        
        download.task?.cancel(byProducingResumeData: { data in
            download.resumeData = data
        })
        
        download.state = .paused
    }
    
    func resume(_ image: ImageResponse) {
        guard let download = downloads[image.links.download] else { return }
        
        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: download.image.links.download)
        }
        
        download.task?.resume()
        download.state = .inProgress
    }
    
    func add(_ image: ImageResponse) {
        let download = Download(image: image)
        download.task = downloadsSession.downloadTask(with: image.links.download)
        downloads[download.image.links.download] = download
        download.state = .notStarted
    }
}
