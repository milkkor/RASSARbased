//
//  RoomObjectInfoView.swift
//  RetroAccess App
//
//  Created by User on 9/1/24.
//

import SwiftUI

/// Model representing information about a detected room object
struct RoomObjectInfo: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let dimensions: String
    let distance: Float
}

/// ViewModel for the room object information display
class RoomObjectInfoViewModel: ObservableObject {
    @Published var objectInfos: [RoomObjectInfo] = []
    @Published var isVisible: Bool = true
}

/// SwiftUI view that displays detected room objects
struct RoomObjectInfoView: View {
    @ObservedObject var viewModel: RoomObjectInfoViewModel
    
    var body: some View {
        if viewModel.isVisible {
            VStack {
                // Header with title and close button
                HStack {
                    Text("Detected Objects")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            viewModel.isVisible = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding([.top, .horizontal])
                
                // Object list or empty state
                if viewModel.objectInfos.isEmpty {
                    Text("No objects detected yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.objectInfos) { info in
                            VStack(alignment: .leading) {
                                Text(info.name)
                                    .font(.headline)
                                Text("Category: \(info.category)")
                                Text("Dimensions: \(info.dimensions)")
                                Text("Distance: \(String(format: "%.2f", info.distance))m")
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding()
            .transition(.move(edge: .bottom))
        } else {
            // Collapsed state - just a button to show the panel
            Button(action: {
                withAnimation {
                    viewModel.isVisible = true
                }
            }) {
                Text("Show Detected Objects")
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 3)
            }
            .padding()
            .transition(.move(edge: .bottom))
        }
    }
} 