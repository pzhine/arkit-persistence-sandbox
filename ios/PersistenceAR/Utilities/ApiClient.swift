//
//  ApiClient.swift
//  PersistenceAR
//
//  Created by Paul on 11/23/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import Foundation

// MARK: API types

// Generic ApiError
struct ApiError: Codable {
    let message: String
}

// Generic API Response
struct ApiResponse: Codable {
//    init(error: ApiError) {
//        error = error
//    }
    var error: ApiError?
    var bytesReceived: Int32?
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
        let url = URL(string: "http://172.20.10.3:5000/api/\(path)")
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
