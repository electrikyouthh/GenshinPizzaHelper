//
//  AddAccountView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//

import SwiftUI
import WebKit

struct AddAccountView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @Environment(\.presentationMode) var presentationMode

    @State private var unsavedName: String = String(format: NSLocalizedString("我的帐号", comment: "my account"))
    @State private var unsavedUid: String = ""
    @State private var unsavedCookie: String = ""
    @State private var unsavedServer: Server = .china
    
    @State private var connectStatus: ConnectStatus = .unknown
    
    @State private var errorInfo: String = ""
    
    @State private var isPresentingConfirm: Bool = false
    @State private var isAlertShow: Bool = false
    @State private var isWebShown: Bool = false
    
    @State private var accountsForSelected: [FetchedAccount] = []
    @State private var selectedAccount: FetchedAccount?
    
    @State private var region: Region = .cn
    
    @State private var loginError: FetchError?
    
    @State private var userData: UserData?

    @Namespace var animation
    
    
    var body: some View {
        List {
            if (connectStatus == .fail) || (connectStatus == .unknown) {
                Section(footer: HStack {
                    Text("你也可以")
                    NavigationLink(destination: AddAccountDetailView(unsavedName: $unsavedName, unsavedUid: $unsavedUid, unsavedCookie: $unsavedCookie, unsavedServer: $unsavedServer, connectStatus: $connectStatus)) {
                        Text("手动设置帐号")
                    }
                }) {
                    
                    Menu {
                        Button("国服") {
                            region = .cn
                            openWebView()
                        }
                        Button("国际服") {
                            region = .global
                            openWebView()
                        }
                    } label: {
                        Text("登录米游社帐号")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            
            if let loginError = loginError {
                Section(footer: Text("DEBUG：" + loginError.message).foregroundColor(Color(UIColor.systemGray))) {
                    Text(LocalizedStringKey(loginError.description))
                        .foregroundColor(.secondary)
                }
            }
            
            if unsavedUid != "" {
                Section(footer: Text("UID: " + unsavedUid)) {
                    InfoEditor(title: "自定义帐号名", content: $unsavedName, placeholderText: unsavedName)
                    // 如果该账号绑定的UID不止一个，则显示Picker选择账号
                    if accountsForSelected.count > 1 {
                        Picker("请选择帐号", selection: $selectedAccount) {
                            ForEach(accountsForSelected, id: \.gameUid) { account in
                                Text(account.nickname + "（\(account.gameUid)）")
                                    .tag(account as FetchedAccount?)
                            }
                        }
                    }
                }
            }
            
            if (connectStatus == .success) || (connectStatus == .testing) {
                NavigationLink(destination: AddAccountDetailView(unsavedName: $unsavedName, unsavedUid: $unsavedUid, unsavedCookie: $unsavedCookie, unsavedServer: $unsavedServer, connectStatus: $connectStatus)) {
                    Text("查看帐号详情")
                }
            }
            
            if (unsavedUid != "") && (unsavedCookie != "") {
                TestSectionView(connectStatus: $connectStatus, uid: $unsavedUid, cookie: $unsavedCookie, server: $unsavedServer)
            }
            
            if let userData = userData {
                GameInfoBlock(userData: userData, accountName: unsavedName, animation: animation, widgetBackground: WidgetBackground.randomNamecardBackground)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .aspectRatio(170/364, contentMode: .fill)
                    .animation(.linear)
                    .listRowBackground(Color.white.opacity(0))
            }
            
        }
        .navigationBarTitle("添加帐号", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    if (unsavedUid == "") || (unsavedCookie == "") {
                        isAlertShow.toggle()
                        return
                    }
                    if unsavedName == "" {
                        unsavedName = unsavedUid
                    }
                    if connectStatus != .success {
                        isAlertShow.toggle()
                        return
                    }
                    viewModel.addAccount(name: unsavedName, uid: unsavedUid, cookie: unsavedCookie, server: unsavedServer)
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        ReviewHandler.requestReview()
                    }
                }
            }
        }
        .alert(isPresented: $isAlertShow) {
            Alert(title: Text("尚未完成帐号设置"))
        }
        .onChange(of: selectedAccount) { value in
            if let selectedAccount = value {
                unsavedName = selectedAccount.nickname
                unsavedUid = selectedAccount.gameUid
                unsavedServer = Server.id(selectedAccount.region)
            }
            connectStatus = .testing
        }
        .sheet(isPresented: $isWebShown) {
            GetCookieWebView(isShown: $isWebShown, cookie: $unsavedCookie, region: region)
        }
        .onChange(of: isWebShown) { isWebShown in
            DispatchQueue.main.async {
                if !isWebShown {
                    getAccountsForSelect()
                }
            }
            
        }
    }
    
    fileprivate func getAccountsForSelect() {
        guard (unsavedCookie != "") else { loginError = .notLoginError(-100, "未获取到登录信息"); return }
        API.Features.getUserGameRolesByCookie(unsavedCookie, region) { result in
            switch result {
            case .success(let fetchedAccountArray):
                accountsForSelected = fetchedAccountArray
                if !accountsForSelected.isEmpty { selectedAccount = accountsForSelected.first! }
                loginError = nil
            case .failure(let fetchError):
                loginError = fetchError
            }
        }
    }

    private func openWebView() -> Void {
        isWebShown.toggle()
    }
}

private enum AlertType {
    case accountNotSaved
}
