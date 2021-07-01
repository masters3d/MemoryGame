//
//  MemorizeGame.swift
//  Masters3dSwiftUI
//
//  Created by Chéyo Jiménez on 5/23/20.
//  Copyright © 2020 masters3d. All rights reserved.
//

import SwiftUI

typealias MemorizeCardSelected = Dictionary<UUID, Emoji>

struct MemorizeGame: View {

    var grid = MemorizeGrid(
                    widthCount: 4,
                    heightCount: 5
                    )

    var game:some View {
        VStack {
        HStack {
            Text("Memory Game").font(.headline)
            Spacer()
        }
         GeometryReader{  geometry in
                self.grid

            }
        }
    }

    var stats:some View {
        VStack {
        HStack {
            Text("Stats").font(.headline)
        }
            Spacer()
            Text("List goes here")
            Spacer()

        }
    }


    var body: some View {

        TabView
        {
            // First Tab
            game.tabItem {
                Image(uiImage: UIImage(systemName: "gamecontroller")!)
                    Text("Game")
                }

            // Next Tab
            stats.tabItem{
                Image(uiImage: UIImage(systemName: "heart")!)
                    Text("Stats")
            }
        }
    }
}

extension CGSize:CustomStringConvertible {
    public var description:String { return NSCoder.string(for: self) }
}

struct MemorizeGrid: View {
    var widthCount: Int
    var heightCount: Int

    private var currentList = [Emoji]()

    @State var isReacting = false

    @State var selectedCardStates = MemorizeCardSelected()

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


struct MemorizeCard: Identifiable, View {


    let timerMatchedCard = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State var isFaceUp = false
    @State var isFirstRun = true
    @State var isMatch = false

    @State var selectedCount = 0
    @Binding var selectedCardStates: MemorizeCardSelected

    @Binding var matchedCards: Dictionary<Emoji, Int>

    func hidingImage(deadlineInSeconds:Int = 2){
        // Turn off after timeout seconds
        let timeout = DispatchTimeInterval.seconds(deadlineInSeconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            self.isFaceUp = false

            selectedCardStates.removeValue(forKey: self.id)

        }
    }

    func toggleVisibilityOfImage() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {

            if selectedCardStates.count < 2 {
                self.isFaceUp.toggle()
            } else if isFaceUp {
                self.isFaceUp.toggle()
            }

            if (isFaceUp) {
                // Show count to user
                selectedCount += 1
                selectedCardStates[self.id] = .init(emojiAsString: self.emojiAsString)
            } else {
                selectedCardStates.removeValue(forKey: self.id)

            }

        }
    }

    func showingAndHiddingImage() {

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.isFaceUp = true
            if(!isFirstRun){
                selectedCount += 1

                selectedCardStates[self.id] = .init(emojiAsString: self.emojiAsString)

            }

        }

        hidingImage()
    }

    func checkIfMatch() -> Bool {

        let currentValues = selectedCardStates.values.map { (memoryCardState) -> String in
            return memoryCardState.emojiAsString
        }

        print("selected: \(currentValues.count) \(currentValues.joined(separator: " "))")

        if matchedCards.keys.contains(self.emoji) {
            return true
        }
       if let valueOfState = self.selectedCardStates[self.id] {
            let emojiAsString = valueOfState.emojiAsString
            var count = 0
            var indexToRemove = [UUID]()
            for (eachIndex, eachValue) in selectedCardStates {
                count +=  eachValue.emojiAsString == emojiAsString ? 1 : 0
                if (eachValue == valueOfState) {
                    indexToRemove.append(eachIndex)
                }
            }
            if count > 1 {
                matchedCards[valueOfState] = count
                // clean up
                for each in indexToRemove {
                    selectedCardStates.removeValue(forKey: each)
                }
            }
        }
        if matchedCards.keys.contains(self.emoji) {
            return true
        }
        return false
    }

    let cornerRadius = CGFloat(25)
    var body: some View {
        ZStack {
            Image(uiImage: ImageCache[
            "\(selectedCount < 1 ? "" : "\(selectedCount)" )"
            ])
            .resizable()
            Image(uiImage: isFaceUp ? emoji.emojiToImage() : ImageCache[""])
            .resizable()
        }
            .animation(.linear)
            .background(isMatch ? Color.green : Color.orange)
            .onAppear{
                defer { isFirstRun = false  }
                guard isFirstRun else { return }
            }
            .onReceive(timerMatchedCard) { _ in
                isMatch = self.checkIfMatch()
                if isMatch {
                    //Cancel timer for cell
                    self.timerMatchedCard.upstream.connect().cancel()
                    self.isFaceUp = false
                }
            }
            .onDisappear {
            }
            .onTapGesture {
                if isMatch {
                // disable tapping if matched already
                 return
                }

                self.toggleVisibilityOfImage()
                self.isMatch = self.checkIfMatch()
            }
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.black, lineWidth: 1)
            )
            .zIndex(0)
            .transition(.slide)// Slide seems to only work when there is more than one thing happening

    }

    var emoji:Emoji
    var id: UUID
    var emojiAsString:String

    init(
        emoji: Emoji,
        selected: Binding<MemorizeCardSelected>,
        matched: Binding<Dictionary<Emoji,Int>>
        )
        {
            self.emoji = emoji
            self.emojiAsString = emoji.emojiAsString
            self.id = UUID()
            self._selectedCardStates = selected
            self._matchedCards = matched
        }
}




struct MemorizeGame_Previews: PreviewProvider {
    static var previews: some View {
        MemorizeGame()
    }
}

