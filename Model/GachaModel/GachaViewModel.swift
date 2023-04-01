//
//  GachaViewModel.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import Combine
import CoreData
import Foundation
import HBMihoyoAPI
import SwiftUI

// MARK: - GachaViewModel

class GachaViewModel: ObservableObject {
    // MARK: Lifecycle

    private init() {
        self.gachaItems = manager.fetchAll()
        refreshAllAvaliableAccountUID()
        filter.uid = allAvaliableAccountUID.first
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refetchGachaItems),
            name: .NSPersistentStoreRemoteChange,
            object: manager
                .persistentStoreCoordinator
        )
    }

    // MARK: Internal

    static let shared: GachaViewModel = .init()

    let manager = GachaModelManager.shared
    /// 祈愿记录和要多少抽才出
    @Published
    var filteredGachaItemsWithCount: [(GachaItem, count: Int)] = []

    @Published
    var allAvaliableAccountUID: [String] = []

    /// 不要直接使用：所有祈愿记录
    @Published
    var gachaItems: [GachaItem] {
        didSet {
            filterGachaItem()
        }
    }

    @Published
    var filter: GachaFilter = .init() {
        didSet {
            filterGachaItem()
        }
    }

    var sortedAndFilteredGachaItem: [GachaItem] {
        gachaItems.sorted { lhs, rhs in
            lhs.id > rhs.id
        }
        .filter { item in
            if let uid = filter.uid {
                return item.uid == uid
            } else {
                return true
            }
        }
        .filter { item in
            item.gachaType == filter.gachaType
        }
    }

    func filterGachaItem() {
        let filteredItems = sortedAndFilteredGachaItem
        let counts = filteredItems.map { item in
            item.rankType
        }.enumerated().map { index, rank in
            let theRestOfArray = filteredItems[(index + 1)...]
            if let nextIndexInRest = theRestOfArray
                .firstIndex(where: { $0.rankType >= rank }) {
                return nextIndexInRest - index
            } else {
                return filteredItems.count - index - 1
            }
        }
        DispatchQueue.main.async {
            self.filteredGachaItemsWithCount = zip(filteredItems, counts)
                .filter { item, _ in
                    switch self.filter.rank {
                    case .five:
                        return item.rankType == .five
                    case .fourAndFive:
                        return [.five, .four].contains(item.rankType)
                    case .threeAndFourAndFire:
                        return true
                    }
                }
        }
    }

    @objc
    func refetchGachaItems() {
        DispatchQueue.main.async {
            withAnimation {
                self.gachaItems = self.manager.fetchAll()
                if self.filter
                    .uid == nil { self.filter.uid = self.gachaItems.first?.uid }
                self.refreshAllAvaliableAccountUID()
            }
        }
    }

    func refreshAllAvaliableAccountUID() {
        allAvaliableAccountUID = [String].init(
            Set<String>(
                gachaItems.map { item in
                    item.uid
                }
            )
        )
    }

    func getGachaAndSaveFor(
        _ account: AccountConfiguration,
        observer: GachaFetchProgressObserver,
        completion: @escaping (
            (Result<(), GetGachaError>)
                -> ()
        )
    ) {
        let group = DispatchGroup()
        group.enter()
        MihoyoAPI.getGachaLogAndSave(
            account: account,
            manager: manager,
            observer: observer
        ) { result in
            switch result {
            case .success:
                group.leave()
            case let .failure(error):
                completion(.failure(error))
            }
        }
        group.notify(queue: .main) {
            self.refetchGachaItems()
            completion(.success(()))
        }
    }

    func getGachaAndSaveFor(
        server: Server,
        authkey: GenAuthKeyResult.GenAuthKeyData,
        observer: GachaFetchProgressObserver,
        completion: @escaping (
            (Result<(), GetGachaError>) -> ()
            )
    ) {
        let group = DispatchGroup()
        group.enter()
        MihoyoAPI.getGachaLogAndSave(server: server, authKey: authkey, manager: manager, observer: observer) { result in
            switch result {
            case .success:
                group.leave()
            case let .failure(error):
                completion(.failure(error))
            }
        }
        group.notify(queue: .main) {
            self.refetchGachaItems()
            completion(.success(()))
        }
    }

}

// MARK: - GachaFilter

struct GachaFilter {
    enum Rank: Int, CaseIterable, Identifiable {
        case five
        case fourAndFive
        case threeAndFourAndFire

        // MARK: Internal

        var id: Int { rawValue }
    }

    var uid: String?
    var gachaType: GachaType = .character
    var rank: Rank = .five
}

// MARK: - GachaFilter.Rank + CustomStringConvertible

extension GachaFilter.Rank: CustomStringConvertible {
    var description: String {
        switch self {
        case .five:
            return "五星"
        case .fourAndFive:
            return "四星及五星"
        case .threeAndFourAndFire:
            return "所有记录"
        }
    }
}

// MARK: - GachaFetchProgressObserver

public class GachaFetchProgressObserver: ObservableObject {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static var shared: GachaFetchProgressObserver = .init()

    @Published
    var page: Int = 0
    @Published
    var gachaType: _GachaType = .standard
    @Published
    var currentItems: [GachaItem_FM] = []
    @Published
    var newItemCount: Int = 0
    @Published
    var gachaTypeDateCounts: [GachaTypeDateCount] = []
    var shouldCancel: Bool = false

    func initialize() {
        withAnimation {
            page = 0
            gachaType = .standard
            currentItems = []
            newItemCount = 0
            gachaTypeDateCounts = []
            shouldCancel = false
        }
    }

    func fetching(page: Int, gachaType: _GachaType) {
        DispatchQueue.main.async {
            withAnimation {
                self.page = page
                self.gachaType = gachaType
            }
        }
    }

    func got(_ items: [GachaItem_FM]) {
        cancellables.append(
            Publishers.Zip(
                items.publisher,
                Timer.publish(
                    every: MihoyoAPI.GET_GACHA_DELAY_RANDOM_RANGE
                        .lowerBound / 20.0,
                    on: .main,
                    in: .default
                )
                .autoconnect()
            )
            .map(\.0)
            .sink(receiveValue: { newItem in
                withAnimation {
                    self.currentItems.append(newItem)
                    self.updateGachaItemCount(item: newItem)
                }
            })
        )
//        self.currentItems.append(contentsOf: items)
    }

    func updateGachaItemCount(item: GachaItem_FM) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: item.time)!
        let type = GachaType.from(item.gachaType)
        if gachaTypeDateCounts
            .filter({ ($0.date == date) && ($0.type == type) }).isEmpty {
            let count = GachaTypeDateCount(
                date: date,
                count: currentItems
                    .filter {
                        (dateFormatter.date(from: $0.time)! <= date) &&
                            (GachaType.from($0.gachaType) == type)
                    }.count,
                type: .from(item.gachaType)
            )
            gachaTypeDateCounts.append(count)
        }
        gachaTypeDateCounts.allIndices { element in
            (element.date >= date) && (element.type == type)
        }.forEach { index in
            self.gachaTypeDateCounts[index].count += 1
        }
    }

    func saveNewItemSucceed() {
        DispatchQueue.main.async {
            withAnimation {
                self.newItemCount += 1
            }
        }
    }

    // MARK: Private

    private var cancellables: [AnyCancellable] = []
}

extension Array where Element: Equatable {
    func allIndices(where predicate: (Self.Element) -> Bool) -> [Self.Index] {
        enumerated().filter { _, element in
            predicate(element)
        }.map { index, _ in
            index
        }
    }
}

// MARK: - GachaTypeDateCount

struct GachaTypeDateCount: Hashable, Identifiable {
    let date: Date
    var count: Int
    let type: GachaType

    var id: Int {
        hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(type)
    }
}
