//
//  ExpeditionInfoBar.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/7.
//

import SwiftUI

struct ExpeditionInfoBar: View {
    let expeditionInfo: ExpeditionInfo
    let expeditionViewConfig: ExpeditionViewConfiguration
    
    var notice: Bool {
        expeditionViewConfig.noticeExpeditionWhenAllCompleted ? expeditionInfo.allCompleted : expeditionInfo.anyCompleted
    }
    var isExpeditionAllCompleteImage: Image {
        notice ? Image(systemName: "exclamationmark") : Image(systemName: "figure.walk")
    }
    
    var body: some View {
        HStack(alignment: .center ,spacing: 8) {
            Image("派遣探索")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isExpeditionAllCompleteImage
                .overlayImageWithRingProgressBar(expeditionViewConfig.noticeExpeditionWhenAllCompleted ? expeditionInfo.allCompletedPercentage : expeditionInfo.nextCompletePercentage, scaler: 0.95)
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3"))
            
            switch expeditionViewConfig.expeditionShowingMethod {
            case .byNum, .unknown:
                HStack(alignment: .lastTextBaseline, spacing:1) {
                    Text("\(expeditionInfo.currentOngoingTask)")
                        .foregroundColor(Color("textColor3"))
                        .font(.system(.body, design: .rounded))
                        .minimumScaleFactor(0.2)
                    Text(" / \(expeditionInfo.maxExpedition)")
                        .foregroundColor(Color("textColor3"))
                        .font(.system(.caption, design: .rounded))
                        .minimumScaleFactor(0.2)
                }
            case .byTimePoint:
                if expeditionViewConfig.noticeExpeditionWhenAllCompleted {
                    Text("\(expeditionInfo.allCompleteTime.completeTimePointFromNow)")
                        .foregroundColor(Color("textColor3"))
                        .font(.system(.body, design: .rounded))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                } else {
                    Text("\(expeditionInfo.nextCompleteTime.completeTimePointFromNow)")
                        .foregroundColor(Color("textColor3"))
                        .font(.system(.body, design: .rounded))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                }
            case .byTimeInterval:
                if expeditionViewConfig.noticeExpeditionWhenAllCompleted {
                    Text("\(expeditionInfo.allCompleteTime.describeIntervalShort)")
                        .foregroundColor(Color("textColor3"))
                        .font(.system(.body, design: .rounded))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                } else {
                    Text("\(expeditionInfo.nextCompleteTime.describeIntervalShort)")
                        .foregroundColor(Color("textColor3"))
                        .font(.system(.body, design: .rounded))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                }
            }
        }
    }
}

