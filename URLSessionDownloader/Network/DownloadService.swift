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

    func cancel(_ image: Image) {
        guard let download = downloads[image.url] else { return }
        
        download.task?.cancel()
        // TODO: specify state here
    }
    
    func pause(_ image: Image) {
        //        guard let download = activeDownloads[image.url], download.isDownloading else { return }
        guard let download = downloads[image.url] else { return }

        download.task?.cancel(byProducingResumeData: { data in
            download.resumeData = data
        })
        
        download.state = DownloadState.paused
    }
    
    func resume(_ image: Image) {
        guard let download = downloads[image.url] else { return }
        
        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
//            download.task?.resume()
            print("here")
        } else {
            download.task = downloadsSession.downloadTask(with: download.image.url)
        }
        
        download.task?.resume()
        download.state = DownloadState.inProgress
    }
    
    func add(_ image: Image) {
        let download = Download(image: image)
        download.task = downloadsSession.downloadTask(with: image.url)
        downloads[download.image.url] = download
    }
}
