//
//  TitleView.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 4/10/23.
//

import SwiftUI

struct TitleView: View {
    var title: String

    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Rectangle()
            .frame(height: 120)
            .foregroundStyle(.black)
            .overlay(
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .offset(y: 10)
            )
            .ignoresSafeArea()
    }
}
