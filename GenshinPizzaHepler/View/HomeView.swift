//
//  HomeView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/22.
//  展示所有账号的主页

import AlertToast
import Defaults
import HBMihoyoAPI
import HoYoKit
import SFSafeSymbols
import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    @FetchRequest(sortDescriptors: [.init(
        keyPath: \AccountConfiguration.priority,
        ascending: true
    )])
    var accounts: FetchedResults<AccountConfiguration>

    var body: some View {
        NavigationView {
            List {
                Group {
                    TodayMaterialEventView()
                    if accounts.isEmpty {
                        AddNewAccountButton()
                            .listRowBackground(Color.white.opacity(0))
                    } else {
                        ForEach(accounts) { account in
                            AccountInfoCardView(account: account)
                        }
                    }
                }
            }
            .refreshable {
                globalDailyNoteCardRefreshSubject.send(())
            }
            .navigationTitle("app.home.title")
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - AccountInfoCardView

struct AccountInfoCardView: View {
    // MARK: Lifecycle

    init(account: AccountConfiguration) {
        self._dailyNoteViewModel = .init(wrappedValue: DailyNoteViewModel(account: account))
    }

    // MARK: Internal

    @Environment(\.scenePhase)
    var scenePhase

    var account: AccountConfiguration { dailyNoteViewModel.account }

    var status: DailyNoteViewModel.Status { dailyNoteViewModel.dailyNoteStatus }

    var body: some View {
        Section {
            switch status {
            case let .succeed(dailyNote, _):
                NoteView(dailyNote: dailyNote, account: account)
            case let .failure(error):
                ErrorView(account: account, error: error)
            case .progress:
                ProgressView().id(UUID())
            }
        } header: {
            Text(account.safeName)
                .foregroundColor(.primary)
                .font(.headline)
        }
        .onChange(of: scenePhase, perform: { newPhase in
            switch newPhase {
            case .active:
                dailyNoteViewModel.getDailyNote()
            default:
                break
            }
        })
        .onReceive(globalDailyNoteCardRefreshSubject, perform: { _ in
            dailyNoteViewModel.getDailyNoteUncheck()
        })
    }

    // MARK: Private

    private struct NoteView: View {
        // MARK: Internal

        let dailyNote: any DailyNote
        let account: AccountConfiguration

        var body: some View {
            // Resin
            InformationRowView("app.dailynote.card.resin.label") {
                let resinIntel = dailyNote.resinInformation
                HStack(spacing: 10) {
                    Image("树脂")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.1)
                        .frame(width: iconFrame, height: iconFrame)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(verbatim: "\(resinIntel.currentResin)")
                            .font(.title)
                        Text(verbatim: " / \(resinIntel.maxResin)")
                            .font(.caption)
                        Spacer()
                        if resinIntel.resinRecoveryTime > Date() {
                            (
                                Text(resinIntel.resinRecoveryTime, style: .relative)
                                    + Text(verbatim: "\n")
                                    + Text(dateFormatter.string(from: resinIntel.resinRecoveryTime))
                            )
                            .multilineTextAlignment(.trailing)
                            .font(.caption2)
                        }
                    }
                }
            }
            // Daily Task
            InformationRowView("app.dailynote.card.dailyTask.label") {
                let dailyTask = dailyNote.dailyTaskInformation
                HStack(spacing: 10) {
                    Image("每日任务")
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconFrame, height: iconFrame)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(verbatim: "\(dailyTask.finishedTaskCount)")
                            .font(.title)
                        Text(verbatim: " / \(dailyTask.totalTaskCount)")
                            .font(.caption)
                        Spacer()
                        switch dailyTask.isExtraRewardReceived {
                        case true:
                            Text("app.dailynote.card.dailyTask.extraReward.received")
                                .font(.caption2)
                        case false:
                            Text("app.dailynote.card.dailyTask.extraReward.notReceived")
                                .font(.caption2)
                        }
                    }
                }
            }
            // Coin
            InformationRowView("app.dailynote.card.homeCoin.label") {
                let homeCoin = dailyNote.homeCoinInformation
                HStack(spacing: 10) {
                    Image("洞天宝钱")
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconFrame * 0.9, height: iconFrame * 0.9)
                        .frame(width: iconFrame, height: iconFrame)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(verbatim: "\(homeCoin.currentHomeCoin)")
                            .font(.title)
                        Text(verbatim: " / \(homeCoin.maxHomeCoin)")
                            .font(.caption)
                        Spacer()
                        if homeCoin.fullTime > Date() {
                            (
                                Text(homeCoin.fullTime, style: .relative)
                                    + Text(verbatim: "\n")
                                    + Text(dateFormatter.string(from: homeCoin.fullTime))
                            )
                            .multilineTextAlignment(.trailing)
                            .font(.caption2)
                        }
                    }
                }
            }
            // Expedition
            InformationRowView("app.dailynote.card.expedition.label") {
                let expeditionInfo = dailyNote.expeditionInformation
                HStack(spacing: 10) {
                    Image("派遣探索")
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconFrame, height: iconFrame)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(verbatim: "\(expeditionInfo.ongoingExpeditionCount)")
                            .font(.title)
                        Text(verbatim: " / \(expeditionInfo.maxExpeditionsCount)")
                            .font(.caption)
                        Spacer()
                        HStack {
                            ForEach(expeditionInfo.expeditions, id: \.iconURL) { expedition in
                                AsyncImage(url: expedition.iconURL) { image in
                                    GeometryReader { g in
                                        image.resizable().scaleEffect(1.4)
                                            .scaledToFit()
                                            .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
                                    }
                                } placeholder: {
                                    ProgressView().id(UUID())
                                }
                                .overlay(
                                    Circle()
                                        .stroke(expedition.isFinished ? .green : .secondary, lineWidth: 3)
                                )
                                .frame(width: 30, height: 30)
                            }
                        }
                    }
                }
            }
        }

        // MARK: Private

        private let iconFrame: CGFloat = 40

        private let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateFormatter.doesRelativeDateFormatting = true
            return dateFormatter
        }()
    }

    @StateObject
    private var dailyNoteViewModel: DailyNoteViewModel
}

// MARK: - DailyNoteViewModel

class DailyNoteViewModel: ObservableObject {
    // MARK: Lifecycle

    /// Initializes a new instance of the view model.
    ///
    /// - Parameter account: The account for which the daily note will be fetched.
    init(account: AccountConfiguration) {
        self.account = account
        Task {
            await getDailyNoteUncheck()
        }
    }

    // MARK: Internal

    enum Status {
        case succeed(dailyNote: any DailyNote, refreshDate: Date)
        case failure(error: AnyLocalizedError)
        case progress(Task<(), Never>?)
    }

    /// The current daily note.
    @Published
    private(set) var dailyNoteStatus: Status = .progress(nil)

    /// The account for which the daily note is being fetched.
    let account: AccountConfiguration

    /// Fetches the daily note and updates the published `dailyNote` property accordingly.
    @MainActor
    func getDailyNote() {
        if case let .succeed(_, refreshDate) = dailyNoteStatus {
            // check if note is older than 15 minutes
            let shouldUpdateAfterMinute: Double = 15
            let shouldUpdateAfterSecond = 60.0 * shouldUpdateAfterMinute

            if Date().timeIntervalSince(refreshDate) > shouldUpdateAfterSecond {
                getDailyNoteUncheck()
            }
        } else if case .progress = dailyNoteStatus {
            return // another operation is already in progress
        } else {
            getDailyNoteUncheck()
        }
    }

    /// Asynchronously fetches the daily note using the MiHoYoAPI with the account information it was initialized with.
    @MainActor
    func getDailyNoteUncheck() {
        if case let .progress(task) = dailyNoteStatus {
            task?.cancel()
        }
        let task = Task {
            do {
                let result = try await account.dailyNote()
                withAnimation {
                    dailyNoteStatus = .succeed(dailyNote: result, refreshDate: Date())
                }
            } catch {
                withAnimation {
                    dailyNoteStatus = .failure(error: AnyLocalizedError(error))
                }
            }
        }
        dailyNoteStatus = .progress(task)
    }
}

// MARK: - TodayMaterialEventView

struct TodayMaterialEventView: View {
    @Environment(\.scenePhase)
    var scenePhase

    @State
    var eventContents: [EventModel] = []

    var body: some View {
        InAppMaterialNavigator()
            .onChange(of: scenePhase, perform: { newPhase in
                switch newPhase {
                case .active:
                    getCurrentEvent()
                default:
                    break
                }
            })
            .onAppear {
                if eventContents.isEmpty {
                    getCurrentEvent()
                }
            }
        CurrentEventNavigator(eventContents: $eventContents)
    }

    func getCurrentEvent() {
        DispatchQueue.global().async {
            API.OpenAPIs.fetchCurrentEvents { result in
                switch result {
                case let .success(events):
                    withAnimation {
                        eventContents = [EventModel](events.event.values)
                        eventContents = eventContents.sorted {
                            $0.endAt < $1.endAt
                        }
                    }
                case .failure:
                    break
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func myRefreshable(action: @escaping () -> ()) -> some View {
        refreshable {
            action()
        }
    }
}

// MARK: - AddNewAccountButton

private struct AddNewAccountButton: View {
    // MARK: Internal

    @State
    var isNewAccountSheetShow: Bool = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Label("settings.account.addAccount", systemSymbol: .plusCircle)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.blue, lineWidth: 4)
                    )
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                    .contentShape(RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    ))
                    .clipShape(RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    ))
                    .onTapGesture {
                        isNewAccountSheetShow.toggle()
                    }
                    .sheet(isPresented: $isNewAccountSheetShow) {
                        CreateAccountSheetView(
                            account: AccountConfiguration(context: viewContext),
                            isShown: $isNewAccountSheetShow
                        )
                    }
                Spacer()
            }
        }
    }

    // MARK: Private

    @Environment(\.managedObjectContext)
    private var viewContext
}

// MARK: - ErrorView

private struct ErrorView: View {
    // MARK: Internal

    let account: AccountConfiguration
    var error: Error

    var body: some View {
        Button {
            isEditAccountSheetShown.toggle()
        } label: {
            switch error {
            case MiHoYoAPIError.verificationNeeded:
                Label {
                    Text("app.dailynote.card.error.need_verification.button")
                } icon: {
                    Image(systemSymbol: .questionmarkCircle)
                        .foregroundColor(.yellow)
                }
            default:
                Label {
                    Text("app.dailynote.card.error.other_error.button")
                } icon: {
                    Image(systemSymbol: .exclamationmarkCircle)
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $isEditAccountSheetShown, content: {
            EditAccountSheetView(account: account, isShown: $isEditAccountSheetShown)
        })
    }

    // MARK: Private

    @State
    private var isEditAccountSheetShown: Bool = false
}
