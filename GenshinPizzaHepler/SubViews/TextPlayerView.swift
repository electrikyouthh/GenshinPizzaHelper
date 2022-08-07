//
//  TextPlayerView.swift
//  GenshinPizzaHepler
//
//  Created by Bill Haku on 2022/8/6.
//

import SwiftUI

struct TextPlayerView: View {
    var title: String
    var text: String
    var nvTitle: String? = nil

    var body: some View {
        List {
            Section(header: Text(title)) {
                Text(text)
            }
        }
        .navigationBarTitle(nvTitle ?? title, displayMode: .inline)
    }
}
