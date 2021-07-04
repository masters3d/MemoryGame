//
//  MemorizeCard.swift
//  MemoryGame
//
//  Created by Cheyo Jimenez on 7/3/21.
//

import SwiftUI

struct MemorizeCard: Identifiable, View {

    @Binding var matchedCards: Dictionary<EmojiValue, Int>

    @Binding var currentList:[EmojiState]

    func toggleVisibilityOfImage() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {

            var temp = emoji
            temp.isFaceUp.toggle()
                currentList[index] = temp

            if (emoji.isFaceUp) {
                // Show count to user
                var temp2 = emoji
                temp2.selectedCount += 1
                currentList[index] = temp2
            }
        }
    }


    let cornerRadius = CGFloat(25)
    var body: some View {
    GeometryReader { metrics in
        ZStack {
            VStack {
            HStack {
                Spacer(minLength: emoji.isMatch ? 0 : metrics.size.width * 0.65)
                Image(uiImage: ImageCache[
                "\(emoji.selectedCount < 1 ? "" : "\(emoji.selectedCount)" )"
                ])
                .resizable()
            }
                Spacer(minLength: emoji.isMatch ? 0 : metrics.size.height * 0.65)
            }

            Image(uiImage: emoji.isFaceUp && !emoji.isMatch ? emoji.emojiToImage() : ImageCache[""])
            .resizable()
        }
            .animation(.linear)
            .background(emoji.isMatch ? Color.green : Color.orange)
            .onDisappear {
            }
            .onTapGesture {

                print("selected: index \(index)")
                if emoji.isMatch {
                // disable tapping if matched already
                   var temp = emoji
                   temp.isFaceUp = false
                   currentList[index] = temp
                 return
                }

                //  chech if able to flip
                let count = currentList.filter { state in
                    state.isFaceUp && !state.isMatch
                }.count


                if (count < 2) {
                    self.toggleVisibilityOfImage()
                } else if (emoji.isFaceUp)  {
                    self.toggleVisibilityOfImage()
                } else {
                    // notify user only two cards at a time
                }

                print("selected: count \(count)")

            }
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.black, lineWidth: 1)
            )
            .zIndex(0)
            .transition(.slide)// Slide seems to only work when there is more than one thing happening
        }
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
            return emoji.value.emojiAsString
        }
    }

    init(
        index: Int,
        matched: Binding<Dictionary<EmojiValue, Int>>,
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
    @State var current:Array<EmojiState> =  [EmojiState.init(value: EmojiValue.init(emojiAsString: "😎"))]
    @State var matched = Dictionary<EmojiValue, Int>()
    var body: some View {

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
