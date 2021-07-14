//
//  MemorizeGame.swift
//  Masters3dSwiftUI
//
//  Created by Chéyo Jiménez on 5/23/20.
//  Copyright © 2020 masters3d. All rights reserved.
//

import SwiftUI


struct MemorizeGrid: View {

    private static let timeResolution = 0.5

    var timerMatchedCard = Timer.publish(every: MemorizeGrid.timeResolution, on: .main, in: .common).autoconnect()

    @State var currentList = createEmoji()

    @State var secondsSinceStartOfGame = 0.0

    @State var matchedCards = EmojiStats()

    static var widthCount = 4
    static var heightCount = 5

    @State private var isShowingWonAlert = false

    func incrementTimeCounter() {
        secondsSinceStartOfGame += MemorizeGrid.timeResolution
    }

    func updateMatchedStatus() {
        var selected = Dictionary<EmojiValue,(cardCount:Int, selectedCount:Int)>()

        for each in currentList where each.isFaceUp {
           if let (cardCount, selectedCount) = selected[each.value] {
                let valueToInsert = (cardCount:cardCount + 1, selectedCount: selectedCount + each.selectedCount)

                selected[each.value] = valueToInsert
           } else {
                selected[each.value] = (cardCount: 1, selectedCount: each.selectedCount)
           }
        }

        for (key, value) in selected where value.cardCount > 1 {
            matchedCards[key] = value.selectedCount
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

        if !isShowingWonAlert && matchedCount == currentList.count {
            isShowingWonAlert = true
            // Add run history to history array
            let scoreRun = currentList.map {$0.selectedCount}.reduce(0, +)

            runsHistory.append(
            (stats: matchedCards ,score: scoreRun, duration: secondsSinceStartOfGame, timestamp: Date())
            )
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

    @Binding var runsHistory:[HistoryEntry]

    init(runsHistory: Binding<[HistoryEntry]>) {
        self._runsHistory = runsHistory
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
            // SwiftUI: Modifying state during view update, this will cause undefined behavior.

            // NOTE: Readinga @State variable that is changing constantly (perhaps via a timer) makes the view to redraw causing the view to get stuck in an infinite loop of updating which block the main thread thus making it seem like the vieww is frozen.

            var lastRunTime = 0.0
            var lastRunScore = 0
            if let lastRun = runsHistory.last {
                (_, lastRunScore, lastRunTime, _ ) = lastRun
            }

            let button = Alert.Button.default(Text("New Game")) {
                currentList = MemorizeGrid.createEmoji()
                matchedCards = EmojiStats()
                isShowingWonAlert = false
                secondsSinceStartOfGame = 0.0

            }
            return Alert(title: Text("You Won"), message: Text("Your score is: \(lastRunScore). Game time: \(lastRunTime)s"), dismissButton: button)
        }
        .onReceive(timerMatchedCard) {
        _ in
            self.incrementTimeCounter()
            self.updateMatchedStatus()
            self.checkAndAlertWhenDone()
        }
    }
}




#if DEBUG

struct MemorizeGrid_PreviewsWrapper: View {
    @State var runsHistory = [HistoryEntry]()
    var body: some View {
        MemorizeGrid(runsHistory: $runsHistory)
    }
}

struct MemorizeGrid_Previews: PreviewProvider {
    static var previews: some View {
       MemorizeGrid_PreviewsWrapper()
    }
}

#endif
