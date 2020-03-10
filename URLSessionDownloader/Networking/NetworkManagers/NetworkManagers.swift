//
//  NetworkManagers.swift
//  URLSessionDownloader
//
//  Created by Oleh Mykytyn on 10.03.2020.
//  Copyright © 2020 Oleh Mykytyn. All rights reserved.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    var sessionFinished: Bool?
    let session = URLSession.init(configuration: .default)
    
    func fetchImages(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let url = URL(string: "https://api.unsplash.com/photos?client_id=\(Credentials.token)&page=1&per_page=30")!
        let task = self.session.dataTask(with: url) { (data, response, error) in
            completion(data, response, error)
        }
        task.resume()
    }
}
