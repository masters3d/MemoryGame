//
//  MemorizeGame.swift
//  Masters3dSwiftUI
//
//  Created by Chéyo Jiménez on 5/23/20.
//  Copyright © 2020 masters3d. All rights reserved.
//

import SwiftUI


struct MemorizeGrid: View {

    let timerMatchedCard = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    @State var currentList = createEmoji()

    @State var matchedCards = Dictionary<EmojiValue,Int>()

    static var widthCount = 4
    static var heightCount = 5

    @State private var isShowingWonAlert = false

    func updateMatchedStatus() {
        var selected = Dictionary<EmojiValue,Int>()

        for each in currentList where each.isFaceUp {
           if let value = selected[each.value] {
                selected[each.value] = value + 1
           } else {
                selected[each.value] = 1
           }
        }

        for (key, value) in selected where value > 1 {
            matchedCards[key] = value
            for (index,each) in currentList.enumerated() where
                each.value.emojiAsString == key.emojiAsString
            {
                var each = each
                each.isMatch = true
                each.isFaceUp = false
                    currentList[index] = each
            }
        }
    }

    func checkAndAlertWhenDone() {
        let matchedCount = currentList.filter { emojiState in
            emojiState.isMatch
        }.count

        if matchedCount == currentList.count {
            isShowingWonAlert = true
        }
    }

    static func createEmoji() -> [EmojiState] {

        var temp = [EmojiState]()

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
                        let emojiView = MemorizeCard(index: emoji_index, matched: $matchedCards, current: $currentList,
                        width: (Double(geometry.size.width - geometry.safeAreaInsets.leading - geometry.safeAreaInsets.trailing) / Double(MemorizeGrid.widthCount)) - 4,
                        height: (Double(geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom) / Double(MemorizeGrid.heightCount)) - 4
                        )
                        emojiView
                        }
                    }
                }
            }
        }.padding(4)
        .alert(isPresented: $isShowingWonAlert) { () -> Alert in

            let button = Alert.Button.default(Text("New Game")) {
                currentList = MemorizeGrid.createEmoji()
                isShowingWonAlert = false
            }
            return Alert(title: Text("You Won"), message: Text("Your score is: \(currentList.map {$0.selectedCount}.reduce(0, +))"), dismissButton: button)
        }
        .onReceive(timerMatchedCard) {
        _ in
            self.updateMatchedStatus()
            self.checkAndAlertWhenDone()
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
