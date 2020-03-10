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
}

class Download {
    var state: DownloadState = .notStarted
    var progress: Float = 0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    let image: ImageResponse

    init(image: ImageResponse) {
        self.image = image
    }
}
