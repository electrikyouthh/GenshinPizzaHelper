//
//  ContentView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//  根View

import SwiftUI
import WidgetKit

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel

    @Environment(\.scenePhase) var scenePhase

    #if DEBUG
    @State var selection: Int = 1
    #else
    @State var selection: Int = 0
    #endif

    @State var sheetType: ContentViewSheetType? = nil
    @State var newestVersionInfos: NewestVersion? = nil
    @State var isJustUpdated: Bool = false

    var index: Binding<Int> { Binding(
        get: { self.selection },
        set: {
            if $0 != self.selection {
                simpleTaptic(type: .medium)
            }
            self.selection = $0
        }
    )}

    @State var isPopUpViewShow: Bool = false
    @Namespace var animation

    @StateObject var storeManager: StoreManager
    @State var isJumpToSettingsView: Bool = false
    @State var bgFadeOutAnimation: Bool = false

    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let buildVersion = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)!

    var body: some View {
        ZStack {
            TabView(selection: index) {
                HomeView(animation: animation, bgFadeOutAnimation: $bgFadeOutAnimation)
                    .tag(0)
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("概览", systemImage: "list.bullet")
                    }
                // TODO: Remove debug check when ready
                #if DEBUG
                if #available(iOS 15.0, *) {
                    ToolsView()
                        .tag(1)
                        .environmentObject(viewModel)
                        .tabItem {
                            Label("工具", systemImage: "shippingbox")
                        }
                }
                #endif
                SettingsView(storeManager: storeManager)
                    .tag(2)
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("设置", systemImage: "gear")
                    }
            }

            if let showDetailOfAccount = viewModel.showDetailOfAccount {
                AccountDisplayView(account: showDetailOfAccount, animation: animation, bgFadeOutAnimation: $bgFadeOutAnimation)
            }
        }
        .onChange(of: scenePhase, perform: { newPhase in
            switch newPhase {
            case .active:
                // 检查是否同意过用户协议
                let isPolicyShown = UserDefaults.standard.bool(forKey: "isPolicyShown")
                if !isPolicyShown { sheetType = .userPolicy }
                DispatchQueue.main.async {
                    bgFadeOutAnimation = true
                }
                DispatchQueue.main.async {
                    viewModel.fetchAccount()
                }
                DispatchQueue.main.async {
                    viewModel.refreshData()
                }
                UIApplication.shared.applicationIconBadgeNumber = -1

                // 检查最新版本
                checkNewestVersion()

                // 强制显示背景颜色
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    bgFadeOutAnimation = false
                }
            case .inactive:
                WidgetCenter.shared.reloadAllTimelines()
            default:
                break
            }
        })
        .sheet(item: $sheetType) { item in
            switch item {
            case .userPolicy:
                UserPolicyView(sheet: $sheetType)
                    .allowAutoDismiss(false)
            case .foundNewestVersion:
                LatestVersionInfoView(sheetType: $sheetType, newestVersionInfos: $newestVersionInfos, isJustUpdated: $isJustUpdated)
            }
        }
        .onOpenURL { url in
            switch url.host {
            case "settings":
                print("jump to settings")
                isJumpToSettingsView.toggle()
                self.selection = 1
            default:
                return
            }
        }
        .navigate(to: NotificationSettingView().environmentObject(viewModel), when: $isJumpToSettingsView)
    }

    func checkNewestVersion() {
        DispatchQueue.global(qos: .default).async {
            switch AppConfig.appConfiguration {
            case .AppStore:
                API.HomeAPIs.fetchNewestVersion(isBeta: false) { result in
                    newestVersionInfos = result
                    guard let newestVersionInfos = newestVersionInfos else {
                        return
                    }
                    if buildVersion < newestVersionInfos.buildVersion {
                        let checkedUpdateVersions = UserDefaults.standard.object(forKey: "checkedUpdateVersions") as! [Int]?
                        if checkedUpdateVersions != nil {
                            if !(checkedUpdateVersions!.contains(newestVersionInfos.buildVersion)) {
                                sheetType = .foundNewestVersion
                            }
                        } else {
                            sheetType = .foundNewestVersion
                        }
                    } else {
                        let checkedNewestVersion = UserDefaults.standard.integer(forKey: "checkedNewestVersion")
                        if checkedNewestVersion < newestVersionInfos.buildVersion {
                            isJustUpdated = true
                            sheetType = .foundNewestVersion
                            UserDefaults.standard.setValue(newestVersionInfos.buildVersion, forKey: "checkedNewestVersion")
                            UserDefaults.standard.synchronize()
                        }
                    }
                }
            case .Debug, .TestFlight:
                API.HomeAPIs.fetchNewestVersion(isBeta: true) { result in
                    newestVersionInfos = result
                    guard let newestVersionInfos = newestVersionInfos else {
                        return
                    }
                    if buildVersion < newestVersionInfos.buildVersion {
                        let checkedUpdateVersions = UserDefaults.standard.object(forKey: "checkedUpdateVersions") as! [Int]?
                        if checkedUpdateVersions != nil {
                            if !(checkedUpdateVersions!.contains(newestVersionInfos.buildVersion)) {
                                sheetType = .foundNewestVersion
                            }
                        } else {
                            sheetType = .foundNewestVersion
                        }
                    } else {
                        let checkedNewestVersion = UserDefaults.standard.integer(forKey: "checkedNewestVersion")
                        if checkedNewestVersion < newestVersionInfos.buildVersion {
                            isJustUpdated = true
                            sheetType = .foundNewestVersion
                            UserDefaults.standard.setValue(newestVersionInfos.buildVersion, forKey: "checkedNewestVersion")
                            UserDefaults.standard.synchronize()
                        }
                    }
                }
            }
        }
    }
}

enum ContentViewSheetType: Identifiable {
    var id: Int {
        hashValue
    }

    case userPolicy
    case foundNewestVersion
}
