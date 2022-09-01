//
//  HttpMethod.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//

import Foundation

enum Method {
    case post
    case get
    case put
}

struct HttpMethod<T: Codable> {

    /// 综合的http post方法接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - urlStr:String，url的字符串后缀，即request的类型
    ///   - region:Region，请求的服务器地区类型
    ///   - serverID: String，服务器ID
    ///   - cookie: String， 用户Cookie
    ///   - completion:异步返回处理好的data以及报错的类型
    static func commonRequest (
        _ method: Method,
        _ urlStr: String,
        _ region: Region,
        _ serverID: String,
        _ uid: String,
        _ cookie: String,
        completion: @escaping(
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        func get_ds_token(uid: String, server_id: String) -> String {
            let s: String
            switch region {
            case .cn:
                s = "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs"
            case .global:
                s = "okr4obncj8bw5a65hbnn5oo6ixjc3l9w"
            }
            let t = String(Int(Date().timeIntervalSince1970))
            let r = String(Int.random(in: 100000..<200000))
            let q = "role_id=\(uid)&server=\(server_id)"
            let c = "salt=\(s)&t=\(t)&r=\(r)&b=&q=\(q)".md5
            return t + "," + r + "," + c
        }

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {

                // 请求url前缀，后跟request的类型
                let baseStr: String
                let appVersion: String
                let userAgent: String
                let clientType: String
                switch region {
                case .cn:
                    baseStr = "https://api-takumi-record.mihoyo.com/"
                    appVersion = "2.11.1"
                    userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.11.1"
                    clientType = "5"
                case .global:
                    baseStr = "https://bbs-api-os.hoyolab.com/"
                    appVersion = "2.9.1"
                    userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.9.1"
                    clientType = "2"
                }
                // 由前缀和后缀共同组成的url
                var url = URLComponents(string: baseStr + urlStr)!
                url.queryItems = [
                    URLQueryItem(name: "server", value: serverID),
                    URLQueryItem(name: "role_id", value: uid)
                ]
                // 初始化请求
                var request = URLRequest(url: url.url!)
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "DS": get_ds_token(uid: uid, server_id: serverID),
                    "x-rpc-app_version": appVersion,
                    "User-Agent": userAgent,
                    "x-rpc-client_type": clientType,
                    "Referer": "https://webstatic.mihoyo.com/",
                    "Cookie": cookie
                ]
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                URLSession.shared.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(error.localizedDescription)))
                        print(
                            "DataTask error in General HttpMethod: " +
                            error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            
                            let dictionary = try? JSONSerialization.jsonObject(with: data)
                            print(dictionary ?? "None")
                            
                            do {
                                let requestResult = try decoder.decode(T.self, from: data)
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(error.localizedDescription)))
                            }
                            
                            
//                            do {
//                                let requestResult = try decoder.decode(T.self, from: data)
//                            } catch {
//                                print("\(error)")
//                            }
                            
                        }
                    }
                }.resume()
            }
        }
    }
    
    static func commonRequest (
        _ method: Method,
        _ urlStr: String,
        _ region: Region,
        _ cookie: String,
        _ serverId: String?,
        completion: @escaping(
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                
                
                
                // 请求url前缀，后跟request的类型
                let baseStr: String
                let appVersion: String
                let userAgent: String
                switch region {
                case .cn:
                    baseStr = "https://api-takumi.mihoyo.com/"
                    appVersion = "2.11.1"
                    userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.11.1"
                case .global:
                    baseStr = "https://api-account-os.hoyolab.com/"
                    appVersion = "2.9.1"
                    userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.9.1"
                }
                // 由前缀和后缀共同组成的url
                var url = URLComponents(string: baseStr + urlStr)!
                switch region {
                case .cn:
                    url.queryItems = [URLQueryItem(name: "game_biz", value: "hk4e_cn")]
                case .global:
                    url.queryItems = [URLQueryItem(name: "game_biz", value: "hk4e_global"), URLQueryItem(name: "region", value: serverId)]
                }
                // 初始化请求
                var request = URLRequest(url: url.url!)
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "Accept-Encoding": "gzip, deflate, br",
                    "Accept-Language": "zh-CN,zh-Hans;q=0.9",
                    "Accept": "application/json, text/plain, */*",
                    "Origin": "https://webstatic.mihoyo.com",
                    "User-Agent": userAgent,
                    "Connection": "keep-alive",
                    "x-rpc-app_version": appVersion,
                    "Referer": "https://webstatic.mihoyo.com/"
                ]
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                URLSession.shared.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(error.localizedDescription)))
                        print(
                            "DataTask error in General HttpMethod: " +
                            error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            
                            let dictionary = try? JSONSerialization.jsonObject(with: data)
                            print(dictionary ?? "None")
                            
                            do {
                                let requestResult = try decoder.decode(T.self, from: data)
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(error.localizedDescription)))
                            }
                            
                        }
                    }
                }.resume()
            }
        }
    }
}

class API {
    // API方法类，在这里只是一个空壳，以extension的方法扩展
}

// String的扩展，让其具有直接加键值对的功能
extension String {
    func addPara(_ key: String, _ value: String) -> String {
        var str = self
        if str != "" {
            str += "&"
        }
        str += "\(key)=\(value)"
        return str
    }
}
