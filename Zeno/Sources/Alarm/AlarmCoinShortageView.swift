//
//  AlarmCoinShortageView.swift
//  Zeno
//
//  Created by Jisoo HAM on 2023/09/26.
//  Copyright © 2023 https://github.com/gnksbm/Zeno. All rights reserved.
//

import SwiftUI

extension View {
  func tossAlert(
    isPresented: Binding<Bool>,
    title: String,
    primaryButtonTitle: String,
    primaryAction: @escaping () -> Void
  ) -> some View {
    return modifier(
      TossAlertModifier(
        isPresented: isPresented,
        title: title,
        primaryButtonTitle: primaryButtonTitle,
        primaryAction: primaryAction
      )
    )
  }
}

struct AlarmCoinShortageView: View {
    @Binding var isPresented: Bool
    let title: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void

    var body: some View {
      VStack(spacing: 22) {
        Image("caution")
          .resizable()
          .scaledToFit()
          .frame(width: 60)

        Text(title)
          .font(.title2)
          .bold()
          .foregroundColor(.black)

        Divider()

        HStack {
          Text("보유하고 있는 코인 : 40")
        }
        .font(.title2)

        Button {
          primaryAction()
          isPresented = false
        } label: {
          Text(primaryButtonTitle)
            .font(.title3)
            .bold()
            .frame(maxWidth: .infinity)
        }
        .initialButtonBackgroundModifier(fontColor: .white, color: .purple)
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 18)
      .frame(width: 300)
      .background(
        RoundedRectangle(cornerRadius: 30)
          .stroke(.blue.opacity(0.1))
          .background(
            RoundedRectangle(cornerRadius: 30)
              .fill(.white)
          )
      )
    }
}

struct AlarmCoinShortageView_Previews: PreviewProvider {
    static var previews: some View {
      Text("토스 알러트 테스트")
        .modifier(
          TossAlertModifier(
            isPresented: .constant(true),
            title: "제목",
            primaryButtonTitle: "버튼 이름",
            primaryAction: { })
        )
    }
}
