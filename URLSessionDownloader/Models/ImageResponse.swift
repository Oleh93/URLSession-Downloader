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
    var links: Links    
}

struct Links: Decodable {
    var imageSelf: URL
    var html: URL
    var download: URL
    var download_location: URL

    enum CodingKeys: String, CodingKey {
        case imageSelf = "self"
        case html
        case download
        case download_location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let imageSelfString = try container.decode(String.self, forKey: .imageSelf)
        let htmlString = try container.decode(String.self, forKey: .html)
        let downloadString = try container.decode(String.self, forKey: .download)
        let download_locationString = try container.decode(String.self, forKey: .download_location)
        imageSelf = URL(string: imageSelfString)!
        html = URL(string: htmlString)!
        download = URL(string: downloadString)!
        download_location = URL(string: download_locationString)!
    }
}
