//
//  LoadingSpinnerView.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import SwiftUI

import SwiftUI

struct LoadingSpinnerView:View {
    
    //MARK: - Variables
    @State private var angle:Double = 0
    
    //MARK: - Constants
    
    //MARK: - View
    var body: some View {
        
        ZStack(){
            Circle()
                .stroke(Color(COLOR_LOADING_SPINNER_BACKGROUND), lineWidth: LOADING_SPINNER_STROKE_WIDTH)
                .frame(width: LOADING_SPINNER_SIZE, height: LOADING_SPINNER_SIZE)
            Circle()
                .stroke(Color(COLOR_LOADING_SPINNER_CIRCLE_1), lineWidth: LOADING_SPINNER_STROKE_WIDTH - 5)
                .frame(width: LOADING_SPINNER_SIZE, height: LOADING_SPINNER_SIZE)
            Circle()
                .trim(from: 0.0, to: 0.3)
                .stroke(Color(COLOR_LOADING_SPINNER_CIRCLE_2), lineWidth: LOADING_SPINNER_STROKE_WIDTH - 5)
                .frame(width: LOADING_SPINNER_SIZE, height: LOADING_SPINNER_SIZE)
                .rotationEffect(.degrees(angle), anchor: .center)
                .onAppear() {
                    withAnimation(Animation.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                        angle = 360
                    }
                }
        }
    }
    
}

//MARK: - Preview
struct LoadingSpinnerView_Preview: PreviewProvider {
    
    static var previews: some View {
        Group {
            LoadingSpinnerView()
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 500, height: 500))
        }
    }
    
}


