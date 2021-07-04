//
//  MemorizeGame.swift
//  Masters3dSwiftUI
//
//  Created by Chéyo Jiménez on 5/23/20.
//  Copyright © 2020 masters3d. All rights reserved.
//

import SwiftUI


struct MemorizeGrid: View {
    var widthCount: Int
    var heightCount: Int

    private var currentList = [Emoji]()

    @State var isReacting = false

    @State var selectedCardStates =  Dictionary<UUID, Emoji>()

    @State var matchedCards = Dictionary<Emoji,Int>()

    init(widthCount:Int, heightCount:Int) {
        self.widthCount = widthCount
        self.heightCount = heightCount

        let count = widthCount * heightCount;
        let countHalf = count / 2;

        let half = MemorizeModel.getMemorizeCards(count: countHalf);

        currentList += half
        currentList += half
        currentList.shuffle()

        // Fills up the rest of non pairs with singles
        while(currentList.count < count) {
            currentList += MemorizeModel.getMemorizeCards(count: 1)
        }
    }

    var body: some View {
    GeometryReader { geometry in
        VStack(spacing: 0) {
            ForEach(0..<self.heightCount) { heightIndex in
                HStack(spacing: 0) {
                    ForEach(0..<self.widthCount) { widthIndex in
                        let emoji = self.currentList[(heightIndex * self.widthCount) +  widthIndex]
                        let emojiView = MemorizeCard(
                            emoji: emoji,
                            selected: $selectedCardStates,
                            matched: $matchedCards
                        )
                        emojiView.padding(2)
                        }
                    }
                }
            }
    }.background(isReacting ? Color.red : Color.white)
    .onTapGesture {
        let timeout = DispatchTimeInterval.seconds(1)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.isReacting = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            self.isReacting = false
        }
    }
    }
}




