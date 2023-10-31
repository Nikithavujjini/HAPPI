//
//  HistoryScreenView.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 29/10/23.
//

import SwiftUI

struct HistoryScreenView: View {
    @StateObject var viewModel: FilesViewModel = FilesViewModel()
    var node:NodeModel? = nil
    let adaptiveColumns = [
        GridItem(.adaptive(minimum: 50))
    ]
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.1).edgesIgnoringSafeArea(.all)
            ScrollView {
                       LazyVGrid(columns: [
                           GridItem(.adaptive(minimum: 80, maximum: 90)),
                           GridItem(.adaptive(minimum: 90, maximum: 90)),
                           GridItem(.adaptive(minimum: 180, maximum: 180))
                       ], spacing: 0) {
                          // HStack {
                               Text("Action")
                                   .font(.interBold(size: 20))
                                   .frame(width: 90, height: 40)
                                   .background(Color.accentColor)
                               Text("Date")
                                   .font(.interBold(size: 20))
                                   .frame(width: 95,height: 40)
                                   .background(Color.accentColor)
                               Text("Email")
                                   .font(.interBold(size: 20))
                                   .frame(width: 170,height: 40)
                                   .background(Color.accentColor)
                          // }
                           
                          // Text(item.action)
                           ForEach(viewModel.history, id: \.self) { item in
                               Text(item.action.lowercased())
                                   .font(.interRegular(size: 16))
                                   .frame(width: 80, height: 30)
                                  // .background(Color.blue)
                                   .foregroundColor(.black)
                                   .cornerRadius(10)
                               Text(item.date)
                                   .font(.interRegular(size: 16))
                                   .frame(width: 90, height: 30)
                                  // .background(Color.blue)
                                   .foregroundColor(.black)
                                   .cornerRadius(10)
                               Text(item.email)
                                   .font(.interRegular(size: 16))
                                   .frame(width: 180, height: 30)
                                  // .background(Color.blue)
                                   .foregroundColor(.black)
                                   .cornerRadius(10)
                           }
                       }
                       .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                   }
               
            if viewModel.isLoading {
                LoadingSpinnerView()
            }
        }
        .onAppear {
            viewModel.getReportsHistory(nodeId: node?.id ?? "")
            //  history = getFormattedHistory()
        }
        .navigationTitle("History")
        .navigationGradientBarColor(shouldRefresh: true)
    }
    
    
    
  
    
}

struct History: Identifiable, Hashable {
    var id = UUID()
    
    var action: String
    var date: String
    var email: String
}
struct HistoryScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryScreenView()
    }
}
