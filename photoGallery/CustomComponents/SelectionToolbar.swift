//
//  SelectionToolbar.swift
//  photoGallery
//
//  Created by apple on 06/07/2025.
//

import SwiftUI

struct SelectionToolbar: View {
    @Binding var isSelectionModeActive: Bool
    @Binding var selectedItems: Set<Int>
    
    var mode: ToolbarMode
    var onMove: (() -> Void)? = nil
    var onShare: (() -> Void)? = nil
    var onBulkEdit: (() -> Void)? = nil

    enum ToolbarMode {
        case moveAndShare
        case bulkEditAndShare
        case shareOnly

        var toggleIcon: String {
            switch self {
            case .moveAndShare: return "ellipsis.circle"
            case .bulkEditAndShare: return "ellipsis.circle"
            case .shareOnly: return "square.and.arrow.up.circle"
            }
        }

        var title: String {
            switch self {
            case .moveAndShare: return "Move"
            case .bulkEditAndShare: return "Bulk Edit"
            case .shareOnly: return "Share"
            }
        }
    }

    var body: some View {
        VStack {
            HStack {
                // Toggle selection mode button
                Button(action: {
                    isSelectionModeActive.toggle()
                    if !isSelectionModeActive {
                        selectedItems.removeAll()
                    }
                }) {
                    Image(systemName: isSelectionModeActive ? "xmark.circle" : mode.toggleIcon)
                        .font(.title2)
                        .foregroundColor(Defs.seeGreenColor)
                }
                .padding(5)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 5, x: 5, y: 5)
                
                Spacer()
                
                // If selection mode is active
                if isSelectionModeActive {
                    Text("\(selectedItems.count) selected")
                        .font(.headline)
                        .padding(5)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5, x: 5, y: 5)
                    
                    Spacer()
                    
                    switch mode {
                    case .moveAndShare:
                        Button("Share") {
                            onShare?()
                        }
                        .toolbarButton()

                        Button("Move") {
                            onMove?()
                        }
                        .toolbarButton()
                        
                    case .bulkEditAndShare:
                        Button("Bulk Edit") {
                            onBulkEdit?()
                        }
                        .toolbarButton()
                        
                        Button("Share") {
                            onShare?()
                        }
                        .toolbarButton()

                    case .shareOnly:
                        Button("Share") {
                            onShare?()
                        }
                        .toolbarButton()
                    }

                    Button("Clear") {
                        selectedItems.removeAll()
                    }
                    .toolbarButton()
                }
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

// MARK: - Button Styling Extension
private extension View {
    func toolbarButton() -> some View {
        self
            .padding(5)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5, x: 5, y: 5)
    }
}


//#Preview {
//    SelectionToolbar()
//}
