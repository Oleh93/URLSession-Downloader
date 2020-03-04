//
//  Image.swift
//  URLSessionDownloader
//
//  Created by Oleh Mykytyn on 04.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import Foundation

class Image {
    var url: URL
    var downloaded: Bool = false

    init(url: URL) {
        self.url = url
    }
}
