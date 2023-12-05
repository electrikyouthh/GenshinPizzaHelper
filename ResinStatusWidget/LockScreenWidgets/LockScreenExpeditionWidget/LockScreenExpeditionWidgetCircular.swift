//
//  LockScreenHomeCoinWidgetCircular.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/9/11.
//

import HoYoKit
import SFSafeSymbols
import SwiftUI

@available(iOSApplicationExtension 16.0, *)
struct LockScreenExpeditionWidgetCircular: View {
    @Environment(\.widgetRenderingMode)
    var widgetRenderingMode

    let result: Result<any DailyNote, any Error>

    var body: some View {
        switch widgetRenderingMode {
        case .accented:
            VStack(spacing: 0) {
                Image("icon.expedition")
                    .resizable()
                    .scaledToFit()
                switch result {
                case let .success(data):
                    Text(
                        "\(data.expeditionInformation.ongoingExpeditionCount) / \(data.expeditionInformation.maxExpeditionsCount)"
                    )
                    .font(.system(.body, design: .rounded).weight(.medium))
                case .failure:
                    Image(systemSymbol: .ellipsis)
                }
            }
            #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
            #else
            .padding(.vertical, 2)
            #endif
            .widgetAccentable()
        case .fullColor:
            VStack(spacing: 0) {
                Image("icon.expedition")
                    .resizable()
                    .scaledToFit()
                switch result {
                case let .success(data):
                    Text(
                        "\(data.expeditionInformation.ongoingExpeditionCount) / \(data.expeditionInformation.maxExpeditionsCount)"
                    )
                    .font(.system(.body, design: .rounded).weight(.medium))
                case .failure:
                    Image(systemSymbol: .ellipsis)
                }
            }
            #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
            #else
            .padding(.vertical, 2)
            #endif
        default:
            VStack(spacing: 0) {
                Image("icon.expedition")
                    .resizable()
                    .scaledToFit()

                switch result {
                case let .success(data):
                    Text(
                        "\(data.expeditionInformation.ongoingExpeditionCount) / \(data.expeditionInformation.maxExpeditionsCount)"
                    )
                    .font(.system(.body, design: .rounded).weight(.medium))
                case .failure:
                    Image(systemSymbol: .ellipsis)
                }
            }
            #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
            #else
            .padding(.vertical, 2)
            #endif
        }
    }
}
