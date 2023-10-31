//
//  FilesListItemView.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 17/10/23.
//

import SwiftUI

struct FilesListItemView: View {
    var node: NodeModel
    init(node: NodeModel) {
        self.node = node
    }
    var body: some View {
        ZStack {
         //   Color.blue.opacity(0.1).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Image(ASSET_IMAGE_FILE_TYPE_IMAGE)
                    Text(node.name)
                        .font(.title3)
                    
                    Spacer()
                    if let properties = node.properties {
                        
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24,height: 24)
                            .foregroundColor(properties.reviewed ?? false ? Color.green : Color.yellow)
                        Text(properties.reviewed ?? false ? "Reviewed" : "In progress")
                            .font(.interLight(size: 13))
                    }
                }
               
            }
           // .background(Color.blue.opacity(0.1))
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            .contentShape(Rectangle())
            
        }
       // Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct FilesListItemView_Previews: PreviewProvider {
    static var previews: some View {
        FilesListItemView(node: NodeModel(id: "", name: "File_129382", mimeType: "application/octet-stream", contentSize: 0))
    }
}
