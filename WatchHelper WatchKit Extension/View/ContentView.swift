//
//  ContentView.swift
//  WatchHelper WatchKit Extension
//
//  Created by Bill Haku on 2022/9/8.
//

import Defaults
import SFSafeSymbols
import SwiftUI
import WidgetKit

let testCookie =
    "stuid=114514004; stoken=SANITIZED ltuid=114514004; ltoken=SANITIZED "

// MARK: - ContentView

struct ContentView: View {
//    @EnvironmentObject
//    var viewModel: ViewModel
    @Environment(\.scenePhase)
    var scenePhase

    var body: some View {
        NavigationView {
            //            if viewModel.accounts.isEmpty {
            //                VStack {
            //                    Text("请等待账号从iCloud同步")
            //                        .multilineTextAlignment(.center)
            //                        .padding(.vertical)
            //                    Image(systemSymbol: .icloudAndArrowDown)
            //                    ProgressView()
            //                }
            //            } else {
            //                List {
            //                    ForEach(
            //                        $viewModel.accounts,
            //                        id: \.config.uuid
            //                    ) { $account in
            //                        if account.result != nil {
            //                            NavigationLink(destination: WatchAccountDetailView(
            //                                userData: account.result!,
            //                                accountName: account.config.name,
            //                                uid: account.config.uid
            //                            )) {
            //                                WatchGameInfoBlock(
            //                                    userData: account.result!,
            //                                    accountName: account.config.name,
            //                                    uid: account.config.uid,
            //                                    fetchComplete: account.fetchComplete,
            //                                    background: account.background
            //                                )
            //                            }
            //                            .listRowInsets(.init(
            //                                top: 0,
            //                                leading: 0,
            //                                bottom: 0,
            //                                trailing: 0
            //                            ))
            //                            .clipShape(RoundedRectangle(
            //                                cornerRadius: 10,
            //                                style: .continuous
            //                            ))
            //                            .listRowBackground(Color.white.opacity(0))
            //                        } else {
            //                            ProgressView()
            //                                .padding()
            //                        }
            //                    }
            //                    NavigationLink("nav.category.settings.name") {
            //                        WatchWidgetSettingView()
            //                    }
            //                }
            //                .listStyle(.carousel)
            //            }
            //        }
            //        .onChange(of: scenePhase, perform: { newPhase in
            //            switch newPhase {
            //            case .active:
            //                DispatchQueue.main.async {
            //                    viewModel.fetchAccount()
            //                }
            //                DispatchQueue.main.async {
            //                    viewModel.refreshData()
            //                }
            //            case .inactive:
            //                if #available(watchOSApplicationExtension 9.0, *) {
            //                    WidgetCenter.shared.reloadAllTimelines()
            //                    WidgetCenter.shared.invalidateConfigurationRecommendations()
            //                }
            //            default:
            //                break
            //            }
            //        })
            //        .onAppear {
            //            viewModel.accounts.forEach { account in
            //                viewModel.deleteAccount(account: account)
            //            }
            //
            //            viewModel.addAccount(name: "Lava", uid: "114514001", cookie: testCookie, server: .china)
            //        }
        }
    }
}
