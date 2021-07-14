//
//  PuzzleCard.swift
//  MemoryGame
//
//  Created by Cheyo Jimenez on 7/13/21.
//

import SwiftUI

struct PuzzleCard: Identifiable, View {

    @Binding var currentList:[EmojiState]

    @State private var dragOffset = CGSize.zero

    let cornerRadius = CGFloat(25)

    var body: some View {
    GeometryReader { metrics in
        Image(uiImage: emoji.emojiToImage())
        .resizable()
        .background(emoji.isMatch ? Color.green : Color.orange)
        .frame(width: width, height: height, alignment: Alignment.center)
        .offset(dragOffset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation
                }
                .onEnded { gesture in
                    dragOffset = .zero
                }
            )
        }
    }

    var width:Double
    var height:Double

    var index:Int
    var emoji:EmojiState {
        get {
            return currentList[index]
        }
    }
    var id: UUID
    var emojiAsString:String {
        get {
            return emoji.value.emojiAsString
        }
    }

    init(
        index: Int,
        current: Binding<Array<EmojiState>>,
        width: Double,
        height: Double
        )
        {
            self.id = UUID()
            self.index = index
            self._currentList = current
            self.width = width
            self.height = height
        }
}
