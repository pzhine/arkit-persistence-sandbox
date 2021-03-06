//
//  ApiClient.swift
//  WorldAsSupport
//
//  Created by Paul on 11/23/19.
//  Copyright © 2019 UPF. All rights reserved.
//

import Foundation

// MARK: API types
// https://www.raywenderlich.com/3418439-encoding-and-decoding-in-swift#toc-anchor-007

struct ApiWorldDoc: Codable {
    let _id: String
    let lastModified: Date
}

struct ApiWorld: Codable {
    let _id: String
    let currentVersion: String
    let name: String
}

struct ApiError: Codable {
    let message: String
}

struct ApiResponse: Codable {
    var error: ApiError?
    
    // for uploads
    var bytesReceived: Int32?
    
    // get: worlds
    var worlds: [ApiWorld]?
    
    // get: world-docs/:id
    var worldDoc: ApiWorldDoc?
}

// MARK: API Client

class ApiClient {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.dateFormatter)
        return encoder
    }()
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.dateFormatter)
        return decoder
    }()
    
    static func makeApiRequest(path: String, verb: String, contentType: String = "application/json", accept: String = "application/json") -> URLRequest {
        let url = URL(string: "http://192.168.1.129:5000/api/\(path)")
        var request = URLRequest(url: url!)
        request.httpMethod = verb
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.addValue(accept, forHTTPHeaderField: "Accept")
        return request
    }
    
    static func handleOnComplete(with complete: @escaping (_ : ApiResponse) -> Void) -> (Data?, URLResponse?, Error?) -> Void {
        return { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                complete(ApiResponse(error: ApiError(message: "URLSession error: \(error)")))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                complete(ApiResponse(error: ApiError(message: "Bad HTTPURLResponse")))
                return
            }
            guard let responseJson = try? decoder.decode(ApiResponse.self, from: data!) else {
                complete(ApiResponse(error: ApiError(message: "Malformed response")))
                return
            }
            guard responseJson.error == nil else {
                complete(responseJson)
                return
            }
            guard (200...299).contains(response.statusCode) else {
                complete(ApiResponse(error: ApiError(message: "Unexpected response status: \(response.statusCode)")))
                return
            }
            complete(responseJson)
        }
    }
    
    static func uploadTask(request: URLRequest, data: Data, complete: @escaping (_ : ApiResponse) -> Void) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15.0
        configuration.timeoutIntervalForResource = 300.0
        let session = URLSession(configuration: configuration)
        let task = session.uploadTask(
            with: request,
            from: data,
            completionHandler: handleOnComplete(with: complete)
        )
        task.resume()
    }
    
    static func dataTask(request: URLRequest, complete: @escaping (_ : ApiResponse) -> Void) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15.0
        configuration.timeoutIntervalForResource = 300.0
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(
            with: request,
            completionHandler: handleOnComplete(with: complete)
        )
        task.resume()
    }
    
    static func downloadTask(request: URLRequest, complete: @escaping (_ : URL?, _ : Error?) -> Void) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15.0
        configuration.timeoutIntervalForResource = 300.0
        let session = URLSession(configuration: configuration)
        let task = session.downloadTask(with: request) { url, urlResponse, error in
            complete(url, error)
        }
        task.resume()
    }
}

// MARK: DateFormatter

extension DateFormatter {
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}
