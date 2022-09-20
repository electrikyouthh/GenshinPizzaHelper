//
//  InAppMaterialNavigator.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/25.
//  主页今日材料页面

import SwiftUI

struct InAppMaterialNavigator: View {
    var today: MaterialWeekday = .today()
    var talentMaterialProvider: TalentMaterialProvider { .init(weekday: today) }
    var weaponMaterialProvider: WeaponMaterialProvider { .init(weekday: today) }

    let uuid = UUID()

    @State var showMaterialDetail = false

    @State var showRelatedDetailOfMaterial: WeaponOrTalentMaterial?

    @Namespace var animationMaterial

    let imageWidth = CGFloat(50)

    var body: some View {
        VStack {
            HStack {
                if today != .sunday {
                    Text("今日材料")
                        .padding(.leading, 25)
                        .font(.caption)
                        .padding(.top)
                        .padding(.bottom, -10)
                    if showRelatedDetailOfMaterial != nil {
                        Spacer()
                        Text("左右滑动查看所有角色")
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .padding(.top)
                            .padding(.bottom, -10)
                    } else if showMaterialDetail {
                        Spacer()
                        Text("点击材料查看关联角色")
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .padding(.top)
                            .padding(.bottom, -10)
                    }
                    Spacer()
                    if showMaterialDetail == false {
                        Text(getDate())
                            .padding(.trailing, 25)
                            .font(.caption)
                            .padding(.top)
                            .padding(.bottom, -10)
                    } else {
                        Button("隐藏") {
                            withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 1.0, blendDuration: 0)) {
                                showRelatedDetailOfMaterial = nil
                                showMaterialDetail = false
                            }
                        }
                        .padding(.trailing, 25)
                        .font(.caption)
                        .padding(.top)
                        .padding(.bottom, -10)
                    }
                } else {
                    Text("今日材料")
                        .font(.caption)
                        .padding()
                    Spacer()
                    Group {
                        if showMaterialDetail { Text("点击材料查看关联角色") }
                        else if showRelatedDetailOfMaterial != nil { Text("左右滑动查看所有角色") }
                        else { Text("所有材料均可获取")}
                    }
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .padding()
                    Spacer()
                    if showMaterialDetail == false {
                        Text(getDate())
                            .font(.caption)
                            .padding()
                    } else {
                        Button("隐藏") {
                            withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 1.0, blendDuration: 0)) {
                                showRelatedDetailOfMaterial = nil
                                showMaterialDetail = false
                            }
                        }
                        .font(.caption)
                        .padding()
                    }
                }
            }
            if !showMaterialDetail {
                materials()
            } else {
                if showRelatedDetailOfMaterial == nil {
                    materialsDetail()
                        .padding(.vertical)
                } else {
                    materialRelatedItemView()
                        .padding()
                }

            }
        }
        .blurMaterialBackground()
        .padding(.horizontal)
        .onTapGesture {
            if !showMaterialDetail {
                simpleTaptic(type: .light)
                withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 1.0, blendDuration: 0)) {
                    showMaterialDetail = true
                }
            }
            if showRelatedDetailOfMaterial != nil {
                simpleTaptic(type: .light)
                withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 1.0, blendDuration: 0)) {
                    showRelatedDetailOfMaterial = nil
                }
            }
        }
    }

    @ViewBuilder
    func materials() -> some View {
        if today != .sunday {
            let imageWidth = CGFloat(40)
            HStack(spacing: 0) {
                Spacer()
                ForEach(talentMaterialProvider.todaysMaterials, id: \.imageString) { material in
                    Image(material.imageString)
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: material.imageString, in: animationMaterial)
                        .frame(width: imageWidth)
                        .padding(.vertical)
                }
                Spacer()
                ForEach(weaponMaterialProvider.todaysMaterials, id: \.imageString) { material in
                    Image(material.imageString)
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: material.imageString, in: animationMaterial)
                        .frame(width: imageWidth)
                }
                Spacer()
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func materialsDetail() -> some View {
        VStack {
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    ForEach(talentMaterialProvider.todaysMaterials, id: \.imageString) { material in
                        HStack {
                            Image(material.imageString)
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: material.imageString, in: animationMaterial)
                                .frame(width: imageWidth)
                            Text(material.displayName)
                                .foregroundColor(Color("materialTextColor"))
                                .matchedGeometryEffect(id: material.displayName, in: animationMaterial)
                        }
                        .onTapGesture {
                            withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 1.0, blendDuration: 0))  {
                                showRelatedDetailOfMaterial = material
                            }
                        }
                    }
                }
                Spacer()
                VStack(alignment: .leading) {
                    ForEach(weaponMaterialProvider.todaysMaterials, id: \.imageString) { material in
                        HStack {
                            Image(material.imageString)
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: material.imageString, in: animationMaterial)
                                .frame(width: imageWidth)
                            Text(material.displayName)
                                .foregroundColor(Color("materialTextColor"))
                                .matchedGeometryEffect(id: material.displayName, in: animationMaterial)
                        }
                        .onTapGesture {
                            withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 1.0, blendDuration: 0))  {
                                showRelatedDetailOfMaterial = material
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }

    @ViewBuilder
    func materialRelatedItemView() -> some View {
        if let material = showRelatedDetailOfMaterial {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(material.imageString)
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: material.imageString, in: animationMaterial)
                        .frame(width: imageWidth)
                    Text(material.displayName)
                        .foregroundColor(Color("materialTextColor"))
                        .matchedGeometryEffect(id: material.displayName, in: animationMaterial)
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(material.relatedItem, id: \.imageString) { item in
                            VStack {
                                Image(item.imageString)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75)
                                Text(item.displayName)
                                    .font(.footnote)
                                    .foregroundColor(.init(UIColor.darkGray))
                            }
                        }
                    }
                }
            }
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 1.0, blendDuration: 0))  {
                    showRelatedDetailOfMaterial = nil
                }
            }
        } else {
            EmptyView()
        }
    }

    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMMd EEEE")
        return formatter.string(from: Date())
    }
}
