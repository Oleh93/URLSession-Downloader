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
    
    let session = URLSession.shared
    
    
    func fetchImages(completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        let url = URL(string: "https://api.unsplash.com/photos/random?client_id=\(Credentials.token)")!
        
//        let task = self.session.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                completion(nil, response, error)
//            }
//            if let data = data {
//                completion(data, response, nil)
//            }
//        }
        let task = self.session.dataTask(with: url) { (data, response, error) in
            completion(data, response, error)
        }
        task.resume()
    }
}
