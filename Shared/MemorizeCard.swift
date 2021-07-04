//
//  MemorizeCard.swift
//  MemoryGame
//
//  Created by Cheyo Jimenez on 7/3/21.
//

import SwiftUI

struct MemorizeCard: Identifiable, View {

    @Binding var matchedCards: Dictionary<EmojiState, Int>

    @Binding var currentList:[EmojiState]

    func toggleVisibilityOfImage() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {

            var temp = emoji
            temp.isFaceUp.toggle()
                currentList[index] = temp

            if (emoji.isFaceUp) {
                // Show count to user
                var temp = emoji
                temp.selectedCount += 1
                currentList[index] = temp
            }
        }
    }


    let cornerRadius = CGFloat(25)
    var body: some View {
        ZStack {
            Image(uiImage: ImageCache[
            "\(emoji.selectedCount < 1 ? "" : "\(emoji.selectedCount)" )"
            ])
            .resizable()
            Image(uiImage: emoji.isFaceUp ? emoji.emojiToImage() : ImageCache[""])
            .resizable()
        }
            .animation(.linear)
            .background(emoji.isMatch ? Color.green : Color.orange)
            .onDisappear {
            }
            .onTapGesture {
                if emoji.isMatch {
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

    var index:Int
    var emoji:EmojiState {
        get {
            return currentList[index]
        }
    }
    var id: UUID
    var emojiAsString:String {
        get {
            return emoji.emojiAsString
        }
    }

    init(
        index: Int,
        matched: Binding<Dictionary<EmojiState, Int>>,
        current: Binding<Array<EmojiState>>
        )
        {
            self.id = UUID()
            self.index = index
            self._matchedCards = matched
            self._currentList = current
        }
}

#if DEBUG
struct MemorizeCard_Previews_Wrapper:View {
    @State var current = Array<EmojiState>()
    @State var matched = Dictionary<EmojiState, Int>()
    var body: some View {
           current.append(EmojiState.init(emojiAsString: "😎"))

            return  MemorizeCard(index: 0, matched: $matched, current: $current)
            .frame(width: 150, height: 150, alignment: .center)
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
