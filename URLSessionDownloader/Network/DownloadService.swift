//
//  DownloadService.swift
//  URLSessionDownloader
//
//  Created by Oleh Mykytyn on 04.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import Foundation

class DownloadService {
    var activeDownloads: [URL: Download] = [ : ]
    var downloadsSession: URLSession?
    
    func start(_ image: Image) {
      let download = Download(image: image)
      download.task = downloadsSession?.downloadTask(with: image.url)
      download.task?.resume()
      download.isDownloading = true
      activeDownloads[download.image.url] = download
    }

    func cancel(_ image: Image) {
        guard let download = activeDownloads[image.url] else { return }
        
        download.task?.cancel()
        
        activeDownloads[image.url] = nil
    }
    
    func pause(_ image: Image) {
        guard let download = activeDownloads[image.url], download.isDownloading else { return }
        
        download.task?.cancel(byProducingResumeData: { data in
            download.resumeData = data
        })
        
        download.isDownloading = false
    }
    
    func resume(_ image: Image) {
        guard let download = activeDownloads[image.url] else { return }
        
        if let resumeData = download.resumeData {
            download.task = downloadsSession?.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession?.downloadTask(with: download.image.url)
        }
        
        download.task?.resume()
        download.isDownloading = true
    }
}
