//
//  AboutView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/8.
//

import SwiftUI

struct AboutView: View {
    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let buildVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

    var body: some View {
        VStack {
            Image("AppIconHD")
                .resizable()
                .frame(width: 75, height: 75, alignment: .center)
                .cornerRadius(10)
                .padding()
                .padding(.top, 50)
            Text("原神披萨小助手")
                .font(.title3)
                .fontWeight(.regular)
                .foregroundColor(.primary)
            Text("\(appVersion) (\(buildVersion))")
                .font(.callout)
                .fontWeight(.regular)
                .foregroundColor(.secondary)
            Spacer()

            NavigationLink(destination: ContactUsView()) {
                Text("开发者与联系方式")
                    .padding()
                    .font(.callout)
            }
            Text("「原神披萨小助手」与上海米哈游网络科技股份有限公司及其子公司无关。")
                .font(.caption2)
            Text("原神的游戏内容和各种游戏内素材与商标的版权都属于米哈游。")
                .font(.caption2)
        }
    }
}
