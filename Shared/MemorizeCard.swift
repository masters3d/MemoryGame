//
//  MemorizeCard.swift
//  MemoryGame
//
//  Created by Cheyo Jimenez on 7/3/21.
//

import SwiftUI

struct MemorizeCard: Identifiable, View {

    let timerMatchedCard = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State var isFaceUp = false
    @State var isFirstRun = true
    @State var isMatch = false

    @State var selectedCount = 0
    @Binding var selectedCardStates:  Dictionary<UUID, Emoji>

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
        selected: Binding< Dictionary<UUID, Emoji>>,
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

#if DEBUG
struct MemorizeCard_Previews_Wrapper:View {
    @State var selected = Dictionary<UUID, Emoji>()
    @State var matched = Dictionary<Emoji, Int>()
    var body: some View {
              MemorizeCard(emoji: Emoji.init(emojiAsString: "😎"), selected: $selected, matched: $matched).frame(width: 150, height: 150, alignment: .center)
    }
}

struct MemorizeCard_Previews: PreviewProvider {
    static var previews: some View {
        MemorizeCard_Previews_Wrapper()
    }
}
#endif
