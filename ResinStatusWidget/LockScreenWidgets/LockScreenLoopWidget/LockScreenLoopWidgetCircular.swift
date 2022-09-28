//
//  LockScreenHomeCoinWidgetCircular.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/11.
//

import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct LockScreenLoopWidgetCircular: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: FetchResult

    var body: some View {
        switch LockScreenLoopWidgetType.autoChoose(result: result) {
        case .resin:
            AlternativeLockScreenResinWidgetCircular(result: result)
        case .dailyTask:
            LockScreenDailyTaskWidgetCircular(result: result)
        case .expedition:
            LockScreenExpeditionWidgetCircular(result: result)
        case .homeCoin:
            LockScreenHomeCoinWidgetCircular(result: result)
        case .transformer:
            LockScreenLoopWidgetTransformerCircular(result: result)
        case .weeklyBosses:
            LockScreenLoopWidgetWeeklyBossesCircular(result: result)
        }
    }
}

