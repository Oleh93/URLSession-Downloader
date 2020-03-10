//
//  ImageResponse.swift
//  URLSessionDownloader
//
//  Created by Oleh Mykytyn on 10.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import Foundation

struct ImageResponse: Decodable {
    var id: String?
    var alt_description: String?
    var links: Links?
}

struct Links: Decodable {
    var imageSelf: String?
    var html: String?
    var download: String?
    var download_location: String?

    enum CodingKeys: String, CodingKey {
        case imageSelf = "self"
        case html
        case download
        case download_location
    }
}
