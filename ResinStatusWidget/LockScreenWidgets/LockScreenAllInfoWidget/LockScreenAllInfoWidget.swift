//
//  AlternativeWatchCornerResinWidget.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/12.
//

import Defaults
import GIPizzaKit
import HoYoKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LockScreenAllInfoWidgetProvider

struct LockScreenAllInfoWidgetProvider: IntentTimelineProvider {
    // 填入在手表上显示的Widget配置内容，例如："的原粹树脂"
    let recommendationsTag: String

    @available(iOSApplicationExtension 16.0, *)
    func recommendations() -> [IntentRecommendation<SelectOnlyAccountIntent>] {
        let configs = AccountConfigurationModel.shared.fetchAccountConfigs()
        return configs.map { config in
            let intent = SelectOnlyAccountIntent()
            intent.simplifiedMode = true
            intent.account = .init(
                identifier: config.uuid!.uuidString,
                display: config.name! + "(\(config.server.localized))"
            )
            return IntentRecommendation(
                intent: intent,
                description: config.name! + recommendationsTag.localized
            )
        }
    }

    func placeholder(in context: Context) -> AccountOnlyEntry {
        AccountOnlyEntry(
            date: Date(),
            result: .success(GeneralDailyNote.exampleData()),
            accountName: "荧",
            accountUUIDString: nil
        )
    }

    func getSnapshot(
        for configuration: SelectOnlyAccountIntent,
        in context: Context,
        completion: @escaping (AccountOnlyEntry) -> ()
    ) {
        let entry = AccountOnlyEntry(
            date: Date(),
            result: .success(GeneralDailyNote.exampleData()),
            accountName: "荧",
            accountUUIDString: nil
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: SelectOnlyAccountIntent,
        in context: Context,
        completion: @escaping (Timeline<AccountOnlyEntry>) -> ()
    ) {
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let refreshMinute =
            Int(Defaults[.lockscreenWidgetRefreshFrequencyInMinute])
        var refreshDate: Date {
            Calendar.current.date(
                byAdding: .minute,
                value: refreshMinute,
                to: currentDate
            )!
        }

        let accountConfigurationModel = AccountConfigurationModel.shared
        let configs = accountConfigurationModel.fetchAccountConfigs()

        guard !configs.isEmpty else {
            let entry = AccountOnlyEntry(
                date: currentDate,
                result: .failure(FetchError.noFetchInfo),
                accountUUIDString: nil
            )
            let timeline = Timeline(
                entries: [entry],
                policy: .after(refreshDate)
            )
            completion(timeline)
            return
        }

        guard configuration.account != nil else {
            getTimelineEntries(config: configs.first!)
            return
        }

        let selectedAccountUUID = UUID(
            uuidString: configuration.account!
                .identifier!
        )
        print(configs.first!.uuid!, configuration)

        guard let config = configs
            .first(where: { $0.uuid == selectedAccountUUID }) else {
            // 有时候删除账号，Intent没更新就会出现这样的情况
            let entry = AccountOnlyEntry(
                date: currentDate,
                result: .failure(FetchError.noFetchInfo),
                accountUUIDString: nil
            )
            let timeline = Timeline(
                entries: [entry],
                policy: .after(refreshDate)
            )
            completion(timeline)
            print("Need to choose account")
            return
        }

        // 正常情况

        func getTimelineEntries(config: AccountConfiguration) {
            Task {
                do {
                    let data = try await config.dailyNote()
                    let entries = (0 ... 40).map { index in
                        let timeInterval = TimeInterval(index * 8 * 60)
                        let entryDate =
                            Date(timeIntervalSinceNow: timeInterval)
                        return AccountOnlyEntry(
                            date: entryDate,
                            result: .success(data),
                            accountName: config.name,
                            accountUUIDString: config.uuid?.uuidString
                        )
                    }
                } catch {
                    let entry = AccountOnlyEntry(
                        date: currentDate,
                        result: .failure(error),
                        accountName: config.name,
                        accountUUIDString: config.uuid?.uuidString
                    )
                    completion(.init(entries: [entry], policy: .after(refreshDate)))
                }
            }
        }
    }
}

// MARK: - LockScreenAllInfoWidget

@available(iOSApplicationExtension 16.0, *)
struct LockScreenAllInfoWidget: Widget {
    let kind: String = "LockScreenAllInfoWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenAllInfoWidgetProvider(
                recommendationsTag: "的综合信息"
            )
        ) { entry in
            LockScreenAllInfoWidgetView(entry: entry)
                .lockscreenContainerBackground { EmptyView() }
        }
        .configurationDisplayName("综合信息")
        .description("所有信息，一网打尽")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - LockScreenAllInfoWidgetView

@available(iOS 16.0, *)
struct LockScreenAllInfoWidgetView: View {
    @Environment(\.widgetFamily)
    var family: WidgetFamily
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode
    let entry: LockScreenAllInfoWidgetProvider.Entry

    var result: Result<any DailyNote, any Error> { entry.result }
    var accountName: String? { entry.accountName }

    var url: URL? {
        let errorURL: URL = {
            var components = URLComponents()
            components.scheme = "ophelperwidget"
            components.host = "accountSetting"
            components.queryItems = [
                .init(
                    name: "accountUUIDString",
                    value: entry.accountUUIDString
                ),
            ]
            return components.url!
        }()

        switch result {
        case .success:
            return nil
        case .failure:
            return errorURL
        }
    }

    var body: some View {
        Group {
            switch widgetRenderingMode {
            case .fullColor:
                switch result {
                case let .success(data):
                    Grid(
                        alignment: .leadingFirstTextBaseline,
                        horizontalSpacing: 3,
                        verticalSpacing: 2
                    ) {
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.resin"))")
                                .widgetAccentable()
                                .foregroundColor(Color("iconColor.resin"))
                            Text("\(data.resinInformation.calculatedCurrentResin)")
                            Spacer()
                            Text("\(Image("icon.expedition"))")
                                .widgetAccentable()
                                .foregroundColor(
                                    Color("iconColor.expedition")
                                )
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(
                                    "\(data.expeditionInformation.ongoingExpeditionCount)"
                                )
                                Text(
                                    " / \(data.expeditionInformation.maxExpeditionsCount)"
                                )
                                .font(.caption)
                            }
                            Spacer()
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.homeCoin"))")
                                .widgetAccentable()
                                .foregroundColor(
                                    Color("iconColor.homeCoin")
                                )
                            Text("\(data.homeCoinInformation.calculatedCurrentHomeCoin)")
                            Spacer()
                            Text("\(Image("icon.dailyTask"))")
                                .foregroundColor(
                                    Color("iconColor.dailyTask")
                                )
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(
                                    "\(data.dailyTaskInformation.finishedTaskCount)"
                                )
                                Text(
                                    " / \(data.dailyTaskInformation.totalTaskCount)"
                                )
                                .font(.caption)
                            }
                        }
                        if let data = data as? GeneralDailyNote {
                            GridRow(alignment: .lastTextBaseline) {
                                Text("\(Image("icon.transformer"))")
                                    .foregroundColor(
                                        Color("iconColor.transformer")
                                    )
                                    .widgetAccentable()
                                let day = Calendar.current.dateComponents(
                                    [.day],
                                    from: Date(),
                                    to: data.transformerInformation.recoveryTime
                                ).day!
                                Text("\(day)天")
                                Spacer()
                                Text("\(Image("icon.weeklyBosses"))")
                                    .widgetAccentable()
                                    .foregroundColor(
                                        Color("iconColor.weeklyBosses")
                                    )
                                HStack(
                                    alignment: .lastTextBaseline,
                                    spacing: 0
                                ) {
                                    Text(
                                        "\(data.weeklyBossesInformation.remainResinDiscount)"
                                    )
                                    Text(
                                        " / \(data.weeklyBossesInformation.totalResinDiscount)"
                                    )
                                    .font(.caption)
                                }
                                Spacer()
                            }
                        }
                    }
                case .failure:
                    Grid(
                        alignment: .leadingFirstTextBaseline,
                        horizontalSpacing: 3,
                        verticalSpacing: 2
                    ) {
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.resin"))")
                                .widgetAccentable()
                            Text(Image(systemSymbol: .ellipsis))
                            Spacer()
                            Text("\(Image("icon.expedition"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                            Spacer()
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.homeCoin"))")
                                .widgetAccentable()
                            Text("\(Image(systemSymbol: .ellipsis))")
                            Spacer()
                            Text("\(Image("icon.dailyTask"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.transformer"))")
                                .widgetAccentable()
                            Text(Image(systemSymbol: .ellipsis))
                            Spacer()
                            Text("\(Image("icon.weeklyBosses"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                            Spacer()
                        }
                    }
                    .foregroundColor(.gray)
                }

            default:
                switch result {
                case let .success(data):
                    Grid(
                        alignment: .leadingFirstTextBaseline,
                        horizontalSpacing: 3,
                        verticalSpacing: 2
                    ) {
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.resin"))")
                                .widgetAccentable()
                            Text("\(data.resinInformation.calculatedCurrentResin)")
                            Spacer()
                            Text("\(Image("icon.expedition"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(
                                    "\(data.expeditionInformation.ongoingExpeditionCount)"
                                )
                                Text(
                                    " / \(data.expeditionInformation.maxExpeditionsCount)"
                                )
                                .font(.caption)
                            }
                            Spacer()
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.homeCoin"))")
                                .widgetAccentable()
                            Text("\(data.homeCoinInformation.calculatedCurrentHomeCoin)")
                            Spacer()
                            Text("\(Image("icon.dailyTask"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(
                                    "\(data.dailyTaskInformation.finishedTaskCount)"
                                )
                                Text(
                                    " / \(data.dailyTaskInformation.totalTaskCount)"
                                )
                                .font(.caption)
                            }
                        }
                        if let data = data as? GeneralDailyNote {
                            GridRow(alignment: .lastTextBaseline) {
                                Text("\(Image("icon.transformer"))")
                                    .widgetAccentable()
                                let day = Calendar.current.dateComponents(
                                    [.day],
                                    from: Date(),
                                    to: data.transformerInformation.recoveryTime
                                ).day!
                                Text("\(day)天")
                                Spacer()
                                Text("\(Image("icon.weeklyBosses"))")
                                    .widgetAccentable()
                                HStack(
                                    alignment: .lastTextBaseline,
                                    spacing: 0
                                ) {
                                    Text(
                                        "\(data.weeklyBossesInformation.remainResinDiscount)"
                                    )
                                    Text(
                                        " / \(data.weeklyBossesInformation.totalResinDiscount)"
                                    )
                                    .font(.caption)
                                }
                                Spacer()
                            }
                        }
                    }
                case .failure:
                    Grid(
                        alignment: .leadingFirstTextBaseline,
                        horizontalSpacing: 3,
                        verticalSpacing: 2
                    ) {
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.resin"))")
                                .widgetAccentable()
                            Text(Image(systemSymbol: .ellipsis))
                            Spacer()
                            Text("\(Image("icon.expedition"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                            Spacer()
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.homeCoin"))")
                                .widgetAccentable()
                            Text("\(Image(systemSymbol: .ellipsis))")
                            Spacer()
                            Text("\(Image("icon.dailyTask"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.transformer"))")
                                .widgetAccentable()
                            Text(Image(systemSymbol: .ellipsis))
                            Spacer()
                            Text("\(Image("icon.weeklyBosses"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                            Spacer()
                        }
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .widgetURL(url)
    }
}
