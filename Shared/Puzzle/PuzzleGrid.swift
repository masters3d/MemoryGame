//
//  PuzzleGrid.swift
//  MemoryGame
//
//  Created by Cheyo Jimenez on 7/13/21.
//

import SwiftUI

struct PuzzleGrid: View {

    private static let timeResolution = 0.5

    @State var currentList = createEmojiSequence()

    static var widthCount = 4
    static var heightCount = 5

    static func createEmojiSequence() -> [EmojiState] {

        let count = widthCount * heightCount;

        var temp = [EmojiState]()

        for eachIndex in 1...count {
            let toInsert = EmojiState(value: EmojiValue(emojiAsString: "\(eachIndex)"), isFaceUp: true, isMatch: false, selectedCount: 0)
            temp.append(toInsert)
        }
        temp.shuffle()

        return temp
    }

    var body: some View {
    GeometryReader { geometry in
        VStack(spacing: 0) {
            ForEach(0..<MemorizeGrid.heightCount) { heightIndex in
                HStack(spacing: 0) {
                    ForEach(0..<MemorizeGrid.widthCount) { widthIndex in
                        let emoji_index = (heightIndex * MemorizeGrid.widthCount) +  widthIndex
                        let emojiView = PuzzleCard(index: emoji_index, current: $currentList,
                        width: (Double(geometry.size.width - geometry.safeAreaInsets.leading - geometry.safeAreaInsets.trailing) / Double(MemorizeGrid.widthCount)) - 4,
                        height: (Double(geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom) / Double(MemorizeGrid.heightCount)) - 4
                        )
                        emojiView
                        }
                    }
                }
            }
        }.padding(4)
    }
}


