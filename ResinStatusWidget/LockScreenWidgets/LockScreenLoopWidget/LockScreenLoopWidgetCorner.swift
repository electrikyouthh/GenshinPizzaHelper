//
//  LockScreenLoopWidgetCorner.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/14.
//

import HoYoKit
import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct LockScreenLoopWidgetCorner: View {
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode

    let result: Result<any DailyNote, any Error>

    var body: some View {
        switch LockScreenLoopWidgetType.autoChoose(result: result) {
        case .resin:
            LockScreenResinWidgetCorner(result: result)
        case .dailyTask:
            LockScreenDailyTaskWidgetCorner(result: result)
        case .expedition:
            LockScreenExpeditionWidgetCorner(result: result)
        case .homeCoin:
            LockScreenHomeCoinWidgetCorner(result: result)
        }
    }
}
