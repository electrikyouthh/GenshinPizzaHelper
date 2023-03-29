//
//  GetGachaView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2023/3/28.
//

import SwiftUI
import Charts

struct GetGachaView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    @StateObject
    var gachaViewModel: GachaViewModel = .shared
    @StateObject
    var observer: GachaFetchProgressObserver = .shared

    @State var status: Status = .waitToStart
    @State var account: String?

    var body: some View {
        List {
            if status != .running {
                Section {
                    Picker("选择账号", selection: $account) {
                        ForEach(viewModel.accounts.map( { $0.config } ), id: \.uid) { account in
                            Text("\(account.name!) (\(account.uid!))" )
                                .tag(account.uid!)
                        }
                    }
                    Button("获取祈愿记录") {
                        observer.initialize()
                        status = .running
                        let account = account!
                        gachaViewModel.getGachaAndSaveFor(viewModel.accounts.first(where: {$0.config.uid == account})!.config, observer: observer) { result in
                            switch result {
                            case .success(_):
                                withAnimation {
                                    self.status = .succeed
                                }
                            case .failure(let error):
                                withAnimation {
                                    self.status = .failure(error)
                                }
                            }
                        }
                    }
                    .disabled(account == nil)
                }
            } else {
                Section {
                    HStack {
                        Text("正在获取祈愿记录...请等待")
                        Spacer()
                        ProgressView()
                    }
                } footer: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("卡池：\(observer.gachaType.localizedDescription())")
                            Text("页码：\(observer.page)")
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("已获取记录：\(observer.currentItems.count)条")
                            Text("获取到新纪录：\(observer.newItemCount)条")
                        }
                    }

                }
            }

            if #available(iOS 16.0, *) {
                if (status == .succeed) || (status == .running) {
                    Section {
                        GetGachaChart(items: observer.currentItems, data: observer.gachaTypeDateCounts.sorted(by: {$0.date > $1.date}))
                            .padding(.vertical)
                    }
                }
            }

            switch status {
            case .waitToStart:
                EmptyView()
            case .running:

                if let items = observer.currentItems, !items.isEmpty {
                    Section {
                        ForEach(items.reversed()) { item in
                            GachaItemBar(item: item)
                        }
                    } header: {
                        Text("成功获取到一批...")
                    }
                }
            case .succeed:
                Section {
                    Label {
                        Text("获取祈愿记录成功")
                    } icon: {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                    }
                } footer: {
                    Text("获取到\(observer.currentItems.count)条记录，成功保存\(observer.newItemCount)条新记录\n请返回上一级查看，或继续获取其他账号的记录")
                }
                Section {
                    ForEach(observer.currentItems) { item in
                        GachaItemBar(item: item)
                    }
                }
            case .failure(let error):
                Section {
                    Label {
                        Text("获取祈愿记录失败")
                    } icon: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                    }
                    Text("ERROR: \(error.localizedDescription)")
                }
            }
        }
        .onAppear {
            account = viewModel.accounts.first?.config.uid
        }
        .navigationBarBackButtonHidden(status == .running)
    }

    enum Status: Equatable {
        case waitToStart
        case running
        case succeed
        case failure(GetGachaError)
    }
}

private struct GachaItemBar: View {
    let item: GachaItem_FM
    var body: some View {
        VStack(spacing: 1) {
            HStack {
                Label {
                    Text(item.localizedName)
                } icon: {
                    EnkaWebIcon(
                        iconString: item.iconImageName
                    )
                    .scaleEffect(item._itemType == .weapon ? 0.9 : 1)
                    .background(
                        AnyView(item.backgroundImageName())
                    )
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(_GachaType(rawValue: Int(item.gachaType)!)!.localizedDescription())
                        .font(.caption)
                    Text("\(item.formattedTime)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

@available(iOS 16.0, *)
private struct GetGachaChart: View {
    let items: [GachaItem_FM]

    let data: [GachaFetchProgressObserver.GachaTypeDateCount]

    var body: some View {
        Chart(data) {
            LineMark(
                x: .value("日期", $0.date),
                y: .value("抽数", $0.count)
            )
            .foregroundStyle(by: .value("祈愿类型", $0.type.localizedDescription()))
        }
    }
}

