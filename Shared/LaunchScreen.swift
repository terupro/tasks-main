//
//  LaunchScreen.swift
//  Tasks (iOS)
//
//  Created by Teruya Hasegawa on 2022/11/04.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var isLoading = true

    var body: some View {
        if isLoading {
            ZStack {
                Color(.white)
                    .ignoresSafeArea() // ステータスバーまで塗り潰すために必要
                Image("logo")
                    .padding()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        } else {
            Home()
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
