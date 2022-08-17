//
//  GameInfoBlockView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI

struct GameInfoBlock: View {
    var userData: UserData?
    let backgroundColor: WidgetBackgroundColor
    let accountName: String?

    let viewConfig = WidgetViewConfiguration.defaultConfig
    
    
    
    var body: some View {
        
        
        if let userData = userData {
            let transformerCompleted: Bool = userData.transformerInfo.isComplete && userData.transformerInfo.obtained && viewConfig.showTransformer
            let expeditionCompleted: Bool = viewConfig.expeditionViewConfig.noticeExpeditionWhenAllCompleted ? userData.expeditionInfo.allCompleted : userData.expeditionInfo.anyCompleted
            let weeklyBossesNotice: Bool = (viewConfig.weeklyBossesShowingMethod != .neverShow) && !userData.weeklyBossesInfo.isComplete && Calendar.current.isDateInWeekend(Date())
            let dailyTaskNotice: Bool = !userData.dailyTaskInfo.isTaskRewardReceived && (userData.dailyTaskInfo.finishedTaskNum == userData.dailyTaskInfo.totalTaskNum)
            
            // 需要马上上号
            let needToLoginImediately: Bool = (userData.resinInfo.isFull || userData.homeCoinInfo.isFull || expeditionCompleted || transformerCompleted || dailyTaskNotice)
            // 可以晚些再上号，包括每日任务和周本
            let needToLoginSoon: Bool = !userData.dailyTaskInfo.isTaskRewardReceived || weeklyBossesNotice

            HStack {
                Spacer()
                
                
                
                
                VStack(alignment: .leading, spacing: 5) {
                    if let accountName = accountName {
                        
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Image(systemName: "person.fill")
                            Text(accountName)
                            
                        }
                        .font(.footnote)
                        .foregroundColor(Color("textColor3"))
                        
                    }
                    
                    
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        
                        Text("\(userData.resinInfo.currentResin)")
                            .font(.system(size: 50 , design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Color("textColor3"))
                            .shadow(radius: 1)
                        Image("树脂")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 30)
                            .alignmentGuide(.firstTextBaseline) { context in
                                context[.bottom] - 0.17 * context.height
                            }
                    }
                    HStack {
                        if needToLoginImediately {
                            if needToLoginSoon {
                                Image("exclamationmark.circle.questionmark")
                                    .foregroundColor(Color("textColor3"))
                                    .font(.title3)
                            } else {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(Color("textColor3"))
                                    .font(.title3)
                            }
                        } else if needToLoginSoon {
                            Image("hourglass.circle.questionmark")
                                .foregroundColor(Color("textColor3"))
                                .font(.title3)
                        } else {
                            Image(systemName: "hourglass.circle")
                                .foregroundColor(Color("textColor3"))
                                .font(.title3)
                        }
                        RecoveryTimeText(resinInfo: userData.resinInfo)
                    }
                }
                    .padding()
                Spacer()
                DetailInfo(userData: userData, viewConfig: viewConfig)
                    .padding([.vertical])
                    .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
                Spacer()
            }
                .background(LinearGradient(colors: backgroundColor.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
        } else {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }
}
