//
//  InfoPreviewerView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/7.
//  显示具体栏目信息的工具类View

import SwiftUI

// MARK: - InfoPreviewer

struct InfoPreviewer: View {
    enum ContentStyle {
        case standard
        case capsule
    }

    var title: String
    var content: String
    var contentStyle: ContentStyle = .standard
    var textColor: Color = .white
    var backgroundColor: Color = .white

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title.localized))
            Spacer()
            switch contentStyle {
            case .standard:
                Text(content)
                    .foregroundColor(.primary.opacity(0.7))
            case .capsule:
                Text(content)
                    .foregroundColor(textColor)
                    .padding(.horizontal)
                    .background(
                        Capsule()
                            .fill(backgroundColor)
                            .frame(height: 20)
                            .frame(maxWidth: 200)
                            .opacity(0.25)
                    )
            }
        }
    }
}

// MARK: - InfoEditor

struct InfoEditor: View {
    enum Style {
        case vertical
        case horizontal
    }

    var title: String
    @Binding
    var content: String
    var keyboardType: UIKeyboardType = .default
    var placeholderText: String = ""
    var style: Style = .horizontal
    @State
    var contentColor: Color = .init(UIColor.systemGray)

    var body: some View {
        switch style {
        case .horizontal:
            HStack {
                Text(LocalizedStringKey(title))
                Spacer()
                TextEditor(text: $content)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(contentColor)
                    .keyboardType(keyboardType)
                    .onTapGesture { contentColor = Color.primary }
            }
        case .vertical:
            Text(LocalizedStringKey(title))
            TextEditor(text: $content)
                .foregroundColor(contentColor)
                .keyboardType(keyboardType)
                .onTapGesture { contentColor = Color.primary }
        }
    }
}
