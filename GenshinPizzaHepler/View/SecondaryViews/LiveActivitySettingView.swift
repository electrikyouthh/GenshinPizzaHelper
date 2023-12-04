//
//  LiveActivitySettingView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/11/19.
//

import Defaults
import SFSafeSymbols
import SwiftUI

#if canImport(ActivityKit)
@available(iOS 16.1, *)
struct LiveActivitySettingView: View {
    @Binding
    var selectedView: SettingViewIOS16.Navigation?

    @State
    var isAlertShow: Bool = false

    var body: some View {
        Section {
            NavigationLink(value: SettingViewIOS16.Navigation.resinTimerSetting) {
                Label("树脂计时器设置", systemSymbol: .timer)
            }
        } footer: {
            Button("树脂计时器是什么？") {
                isAlertShow.toggle()
            }
            .font(.footnote)
        }
        .alert(
            "若开启，在退出本App时会自动启用一个「实时活动」树脂计时器。默认为顶置的账号，或树脂最少的账号开启计时器。您也可以在「概览」页长按某个账号的卡片手动开启，或启用多个计时器。",
            isPresented: $isAlertShow
        ) {
            Button("OK") {
                isAlertShow.toggle()
            }
        }
    }
}

@available(iOS 16.1, *)
struct LiveActivitySettingDetailView: View {
    // MARK: Internal

    @Environment(\.scenePhase)
    var scenePhase

    @Default(.resinRecoveryLiveActivityUseEmptyBackground)
    var resinRecoveryLiveActivityUseEmptyBackground: Bool
    @Default(.resinRecoveryLiveActivityUseCustomizeBackground)
    var resinRecoveryLiveActivityUseCustomizeBackground: Bool
    @Default(.autoDeliveryResinTimerLiveActivity)
    var autoDeliveryResinTimerLiveActivity: Bool
    @Default(.resinRecoveryLiveActivityShowExpedition)
    var resinRecoveryLiveActivityShowExpedition: Bool
    @Default(.autoUpdateResinRecoveryTimerUsingReFetchData)
    var autoUpdateResinRecoveryTimerUsingReFetchData: Bool

    var useRandomBackground: Binding<Bool> {
        .init {
            !resinRecoveryLiveActivityUseCustomizeBackground
        } set: { newValue in
            resinRecoveryLiveActivityUseCustomizeBackground = !newValue
        }
    }

    var body: some View {
        List {
            if !allowLiveActivity {
                Section {
                    Label {
                        Text("实时活动功能未开启")
                    } icon: {
                        Image(systemSymbol: .exclamationmarkCircle)
                            .foregroundColor(.red)
                    }
                    Button("前往设置开启实时活动功能") {
                        UIApplication.shared
                            .open(URL(
                                string: UIApplication
                                    .openSettingsURLString
                            )!)
                    }
                }
            }

            Group {
                Section {
                    Toggle(
                        "自动启用树脂计时器",
                        isOn: $autoDeliveryResinTimerLiveActivity
                            .animation()
                    )
                }
                Section {
                    Button("如何隐藏灵动岛？如何关闭树脂计时器？") {
                        isHowToCloseDynamicIslandAlertShow.toggle()
                    }
                }
                Section {
                    Toggle(
                        "展示派遣探索",
                        isOn: $resinRecoveryLiveActivityShowExpedition
                    )
                }
                Section {
                    Toggle(
                        "使用透明背景",
                        isOn: $resinRecoveryLiveActivityUseEmptyBackground
                            .animation()
                    )
                    if !resinRecoveryLiveActivityUseEmptyBackground {
                        Toggle(
                            "随机背景",
                            isOn: useRandomBackground.animation()
                        )
                        if resinRecoveryLiveActivityUseCustomizeBackground {
                            NavigationLink("选择背景") {
                                LiveActivityBackgroundPicker()
                            }
                        }
                    }
                } header: {
                    Text("树脂计时器背景")
                }
            }
            .disabled(!allowLiveActivity)
        }
        .sectionSpacing(UIFont.systemFontSize)
        .toolbar {
            ToolbarItem {
                Button {
                    isHelpSheetShow.toggle()
                } label: {
                    Image(systemSymbol: .questionmarkCircle)
                }
            }
        }
        .navigationTitle("树脂计时器设置")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isHelpSheetShow) {
            NavigationView {
                WebBroswerView(
                    url: "https://gi.pizzastudio.org/static/resin_timer_help.html"
                )
                .dismissableSheet(isSheetShow: $isHelpSheetShow)
            }
        }
        .alert(
            "隐藏灵动岛 / 关闭树脂计时器",
            isPresented: $isHowToCloseDynamicIslandAlertShow
        ) {
            Button("OK") {
                isHowToCloseDynamicIslandAlertShow.toggle()
            }
        } message: {
            Text("您可以从左右向中间滑动灵动岛，即可隐藏灵动岛。\n在锁定屏幕上左滑树脂计时器，即可关闭树脂计时器和灵动岛。")
        }
        .onAppear {
            withAnimation {
                allowLiveActivity = ResinRecoveryActivityController.shared
                    .allowLiveActivity
            }
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .active {
                UNUserNotificationCenter.current()
                    .getNotificationSettings { _ in
                        withAnimation {
                            allowLiveActivity =
                                ResinRecoveryActivityController
                                    .shared.allowLiveActivity
                        }
                    }
            }
        }
    }

    // MARK: Private

    @State
    private var isHelpSheetShow: Bool = false

    @State
    private var isHowToCloseDynamicIslandAlertShow: Bool = false

    @State
    private var allowLiveActivity: Bool = ResinRecoveryActivityController
        .shared.allowLiveActivity
}

@available(iOS 16.1, *)
struct LiveActivityBackgroundPicker: View {
    @State
    private var searchText = ""
    @Default(.resinRecoveryLiveActivityBackgroundOptions)
    var resinRecoveryLiveActivityBackgroundOptions: [String]

    var body: some View {
        List {
            ForEach(searchResults, id: \.rawValue) { backgroundImageView in
                HStack {
                    Label {
                        Text(
                            backgroundImageView.localized
                        )
                    } icon: {
                        GeometryReader { g in
                            Image(backgroundImageView.fileName)
                                .resizable()
                                .scaledToFill()
                                .offset(x: -g.size.width)
                        }
                        .clipShape(Circle())
                        .frame(width: 30, height: 30)
                    }
                    Spacer()
                    if resinRecoveryLiveActivityBackgroundOptions
                        .contains(backgroundImageView.fileName) {
                        Button {
                            resinRecoveryLiveActivityBackgroundOptions
                                .removeAll { name in
                                    name == backgroundImageView.fileName
                                }
                        } label: {
                            Image(systemSymbol: .checkmarkCircleFill)
                                .foregroundColor(.accentColor)
                        }
                    } else {
                        Button {
                            resinRecoveryLiveActivityBackgroundOptions
                                .append(backgroundImageView.fileName)
                        } label: {
                            Image(systemSymbol: .checkmarkCircle)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("settings.timer.chooseBackground")
        .navigationBarTitleDisplayMode(.inline)
    }

    var searchResults: [NameCard] {
        if searchText.isEmpty {
            return NameCard.allLegalCases
        } else {
            return NameCard.allLegalCases.filter { cardString in
                cardString.localized.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
#endif
