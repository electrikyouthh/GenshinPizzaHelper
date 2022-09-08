//
//  FetchAPI.swift
//  原神披萨小助手
//
//  Created by Bill Haku on 2022/8/6.
//  主要功能的API

import Foundation

extension API {
    struct Features {
        /// 获取信息
        /// - Parameters:
        ///     - region: 服务器地区
        ///     - serverID: 服务器ID
        ///     - uid: 用户UID
        ///     - cookie: 用户Cookie
        ///     - completion: 数据
        static func fetchInfos (
            region: Region,
            serverID: String,
            uid: String,
            cookie: String,
            completion: @escaping (
                FetchResult
            ) -> ()
        ) {
            // 请求类别
            let urlStr = "game_record/app/genshin/api/dailyNote"
            
            if (uid == "") || (cookie == "") {
                completion(.failure(.noFetchInfo))
            }
            
            // 请求
            HttpMethod<RequestResult>
                .commonRequest(
                    .get,
                    urlStr,
                    region,
                    serverID,
                    uid,
                    cookie
                ) { result in
                    switch result {
                        
                    case .success(let requestResult):
                        print("request succeed")
                        let userData = requestResult.data
                        let retcode = requestResult.retcode
                        let message = requestResult.message
                        
                        switch requestResult.retcode {
                        case 0:
                            print("get data succeed")
                            completion(.success(userData!))
                        case 10001:
                            print("fail 10001")
                            completion(.failure(.cookieInvalid(retcode, message)))
                        case 10103, 10104:
                            print("fail nomatch")
                            completion(.failure(.unmachedAccountCookie(retcode, message)))
                        case 1008:
                            print("fail 1008")
                            completion(.failure(.accountInvalid(retcode, message)))
                        case -1, 10102:
                            print("fail -1")
                            completion(.failure(.dataNotFound(retcode, message)))
                        default:
                            print("unknowerror")
                            completion(.failure(.unknownError(retcode, message)))
                        }
                        
                    case .failure(let requestError):
                        
                        switch requestError {
                        case .decodeError(let message):
                            completion(.failure(.decodeError(message)))
                        default:
                            completion(.failure(.requestError(requestError)))
                        }
                    }
                }
        }
        /// 获取游戏内帐号信息
        /// - Parameters:
        ///     - region: 服务器地区
        ///     - cookie: 用户Cookie
        ///     - completion: 数据
        ///
        /// 只需要Cookie和服务器地区即可返回游戏内的帐号信息等。使用时不知为何需要先随便发送一个请求。
        static func getUserGameRolesByCookie (
            _ cookie: String,
            _ region: Region,
            completion: @escaping (
                Result<[FetchedAccount], FetchError>
            ) -> ()
        ) {
            
            let urlStr = "binding/api/getUserGameRolesByCookie"
            
            guard cookie != "" else { completion(.failure(.noFetchInfo)); print("no cookie got"); return}
            
            switch region {
            case .cn:
                // 先随便发送一个请求
                API.Features.fetchInfos(region: region, serverID: "cn_gf01", uid: "12345678", cookie: cookie) { _ in
                    HttpMethod<RequestAccountListResult>
                        .gameAccountRequest(.get, urlStr, region, cookie, nil) { result in
                            switch result {
                            case .failure(let requestError):
                                switch requestError {
                                case .decodeError(let message):
                                    completion(.failure(.decodeError(message)))
                                default:
                                    completion(.failure(.requestError(requestError)))
                                }
                            case .success(let requestAccountResult):
                                print("request succeed")
                                let accountListData = requestAccountResult.data
                                let retcode = requestAccountResult.retcode
                                let message = requestAccountResult.message
                                
                                switch retcode {
                                case 0:
                                    print("get accountListData succeed")
                                    if accountListData!.list.isEmpty {
                                        completion(.failure(.accountUnbound))
                                    } else {
                                        completion(.success(accountListData!.list))
                                    }
                                case 10001:
                                    print("fail 10001")
                                    completion(.failure(.cookieInvalid(retcode, message)))
                                case -100:
                                    print("fail -100")
                                    completion(.failure(.notLoginError(retcode, message)))
                                default:
                                    print("unknowerror")
                                    completion(.failure(.unknownError(retcode, message)))
                                }
                            }
                        }
                }
            case .global:
                
                var accounts: [FetchedAccount] = []
                let group = DispatchGroup()
                let globalServers: [Server] = [.cht, .asia, .eu, .us]
                globalServers.forEach { server in
                    group.enter()
                    // 先随便发送一个请求
                    API.Features.fetchInfos(region: region, serverID: server.id, uid: "12345678", cookie: cookie) { _ in
                        HttpMethod<RequestAccountListResult>
                            .gameAccountRequest(.get, urlStr, region, cookie, server.id) { result in
                                group.enter()
                                switch result {
                                case .failure(let requestError):
                                    completion(.failure(.requestError(requestError)))
                                case .success(let requestAccountResult):
                                    print("request succeed")
                                    let accountListData = requestAccountResult.data
                                    let retcode = requestAccountResult.retcode
                                    let message = requestAccountResult.message
                                    
                                    switch retcode {
                                    case 0:
                                        accounts.append(contentsOf: accountListData!.list)
                                        group.leave()
                                    case 10001:
                                        print("fail 10001")
                                        completion(.failure(.cookieInvalid(retcode, message)))
                                    case -100:
                                        print("fail -100")
                                        completion(.failure(.notLoginError(retcode, message)))
                                    default:
                                        print("unknowerror")
                                        completion(.failure(.unknownError(retcode, message)))
                                    }
                                }
                                group.leave()
                            }
                    }
                }
                group.notify(queue: DispatchQueue.main) {
                    if accounts.isEmpty { completion(.failure(.accountUnbound)) }
                    else { completion(.success(accounts)) }
                }
            }
        }
    }
}
