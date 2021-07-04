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
    @State var isMatch = false

    @State var selectedCount = 0
    @Binding var currentList:  Dictionary<UUID, Emoji>

    @Binding var matchedCards: Dictionary<Emoji, Int>


    func toggleVisibilityOfImage() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {

            self.isFaceUp.toggle()

            if (isFaceUp) {
                // Show count to user
                selectedCount += 1
            }
        }
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
            .onDisappear {
            }
            .onTapGesture {
                if isMatch {
                // disable tapping if matched already
                 return
                }

                self.toggleVisibilityOfImage()
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
        if #available(iOS 15.0, *) {
                MemorizeCard_Previews_Wrapper()
                .previewInterfaceOrientation(.landscapeRight)
        } else {
            // Fallback on earlier versions
        }
    }
}
#endif
