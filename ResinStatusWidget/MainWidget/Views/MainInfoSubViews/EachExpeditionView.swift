//
//  EachExpeditionView.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2022/8/23.
//  每条探索派遣信息View

import HoYoKit
import SwiftUI

// MARK: - EachExpeditionView

struct EachExpeditionView: View {
    let expedition: any Expedition
    let viewConfig: WidgetViewConfiguration = .defaultConfig
    var useAsyncImage: Bool = false

    var body: some View {
        HStack {
            webView(url: expedition.iconURL)
            if let expedition = expedition as? GeneralDailyNote.ExpeditionInformation.Expedition {
                VStack(alignment: .leading) {
                    Text(intervalFormatter.string(from: TimeInterval.sinceNow(to: expedition.finishTime))!)
                        .lineLimit(1)
                        .font(.footnote)
                        .minimumScaleFactor(0.4)
                    let totalSecond = 20.0 * 60.0 * 60.0
                    let percentage = TimeInterval.sinceNow(to: expedition.finishTime) / totalSecond
                    percentageBar(percentage)
                        .environment(\.colorScheme, .light)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(expedition.isFinished ? "已完成" : "未完成")
                        .lineLimit(1)
                        .font(.footnote)
                        .minimumScaleFactor(0.4)
                    percentageBar(1)
                        .environment(\.colorScheme, .light)
                }
            }
        }
        .foregroundColor(Color("textColor3"))
    }

    @ViewBuilder
    func webView(url: URL) -> some View {
        GeometryReader { g in
            if useAsyncImage {
                WebImage(urlStr: expedition.iconURL.absoluteString)
                    .scaleEffect(1.5)
                    .scaledToFit()
                    .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
            } else {
                NetworkImage(url: expedition.iconURL)
                    .scaleEffect(1.5)
                    .scaledToFit()
                    .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
            }
        }
        .frame(maxWidth: 50, maxHeight: 50)
    }

    @ViewBuilder
    func percentageBar(_ percentage: Double) -> some View {
        let cornerRadius: CGFloat = 3
        GeometryReader { g in
            ZStack(alignment: .leading) {
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .frame(width: g.size.width, height: g.size.height)
                .foregroundStyle(.ultraThinMaterial)
                .opacity(0.6)
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .frame(
                    width: g.size.width * percentage,
                    height: g.size.height
                )
                .foregroundStyle(.thickMaterial)
            }
            .aspectRatio(30 / 1, contentMode: .fit)
//                .preferredColorScheme(.light)
        }
        .frame(height: 7)
    }
}

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
