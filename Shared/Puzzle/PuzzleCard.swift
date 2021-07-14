//
//  PuzzleCard.swift
//  MemoryGame
//
//  Created by Cheyo Jimenez on 7/13/21.
//

import SwiftUI

struct PuzzleCard: Identifiable, View {

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
                Image(uiImage: ImageCache[
                "\(emoji.selectedCount < 1 ? "" : "\(emoji.selectedCount)" )"
                ])
                .resizable()
            }.frame(width: metrics.size.width / (emoji.isMatch ? 1 : 3), height: metrics.size.height / (emoji.isMatch ? 1 : 3), alignment: .center)
            Spacer(minLength: emoji.isMatch ? 0 : metrics.size.height * 0.65)
            }
            VStack {
            Spacer(minLength: emoji.isMatch ? 0 : metrics.size.height * 0.10)

            Image(uiImage: emoji.isFaceUp && !emoji.isMatch ? emoji.emojiToImage() : ImageCache[""])
            .resizable()
            }
        }
            .animation(.linear)
            .background(emoji.isMatch ? Color.green : Color.orange)
            .frame(width: width, height: height, alignment: Alignment.center)
            .onDisappear {
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

    var width:Double
    var height:Double

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
        current: Binding<Array<EmojiState>>,
        width: Double,
        height: Double
        )
        {
            self.id = UUID()
            self.index = index
            self._currentList = current
            self.width = width
            self.height = height
        }
}
