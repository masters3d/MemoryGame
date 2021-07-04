//
//  MemorizeGame.swift
//  Masters3dSwiftUI
//
//  Created by Chéyo Jiménez on 5/23/20.
//  Copyright © 2020 masters3d. All rights reserved.
//

import SwiftUI


struct MemorizeGrid: View {

    @State var currentList = createEmoji()

    @State var matchedCards = Dictionary<Emoji,Int>()

    static var widthCount = 4
    static var heightCount = 5

    static func createEmoji() -> [Emoji] {

        var temp = [Emoji]()

        let count = widthCount * heightCount;
        let countHalf = count / 2;

        let half = MemorizeModel.getMemorizeCards(count: countHalf);

        temp += half
        temp += half
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
                        let emojiView = MemorizeCard(index: emoji_index, matched: $matchedCards, current: $currentList)
                        emojiView.padding(2)
                        }
                    }
                }
            }
        }
    }
}



#if DEBUG

struct MemorizeGrid_Previews: PreviewProvider {
    static var previews: some View {
       MemorizeGrid()
    }
}

#endif
