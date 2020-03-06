//
//  Downloader.swift
//  URLSessionDownloader
//
//  Created by Oleh Mykytyn on 04.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import Foundation

public enum DownloadState {
    case notStarted
    case inProgress
    case paused
    case finished
    case canceled
}

class Download {
    var state: DownloadState = .notStarted
    var progress: Float = 0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    let image: Image

    init(image: Image) {
        self.image = image
    }
}
