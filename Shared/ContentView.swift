//
//  MemorizeGame.swift
//  Masters3dSwiftUI
//
//  Created by Chéyo Jiménez on 5/23/20.
//  Copyright © 2020 masters3d. All rights reserved.
//

import SwiftUI

typealias MemorizeCardSelected = Dictionary<UUID, MemoryCardState>

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

    private var currentList = [MemoryCardState]()

    @State var isReacting = false

    @State var selectedCardStates = MemorizeCardSelected()

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
                        return MemorizeCard(memoryCardState: self.currentList[(heightIndex * self.widthCount) +  widthIndex], seleced: $selectedCardStates)
                            .padding(2)
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

    @State var isFaceUp = false
    @State var isFirstRun = true
    @State var selectedCount = -1
    @Binding var selectedCardStates: MemorizeCardSelected

    func hidingImage(deadlineInSeconds:Int = 2){
        // Turn off after timeout seconds
        let timeout = DispatchTimeInterval.seconds(deadlineInSeconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            self.isFaceUp = false
        }
    }
    func showingAndHiddingImage() {

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.isFaceUp = true
            if(!isFirstRun){
                selectedCount += 1
            }
        }

        hidingImage()
    }
    let cornerRadius = CGFloat(25)
    var body: some View {
        ZStack {
            Image(uiImage: "\(selectedCount < 1 ? "" : "\(selectedCount)" )".emojiToImage())
            .resizable()
            Image(uiImage: isFaceUp ? emoji : "".emojiToImage())
            .resizable()
        }
            .animation(.linear)
            .background(Color.orange)
            .onAppear{
                defer { isFirstRun = false  }
                guard isFirstRun else { return }
                self.showingAndHiddingImage()
            }
            .onTapGesture {
                self.showingAndHiddingImage()
            }
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.black, lineWidth: 1)
            )
            .zIndex(0)
            .transition(.slide)// Slide seems to only work when there is more than one thing happening

    }

    var emoji:UIImage
    var id: UUID
    var emojiAsString:String

    init(memoryCardState: MemoryCardState,
        seleced: Binding<MemorizeCardSelected>)
        {
            self.emoji = memoryCardState.emojiAsString.emojiToImage()
            self.emojiAsString = memoryCardState.emojiAsString
            self.id = memoryCardState.id
            self._selectedCardStates = seleced
        }
}


extension String {
    func emojiToImage() -> UIImage {
            let nsString = (self as NSString)
            let font = UIFont.systemFont(ofSize: 1024)
            let stringAttributes = [NSAttributedString.Key.font: font]
            let imageSize = nsString.size(withAttributes: stringAttributes)

            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
            UIColor.clear.set()
            UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
            nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image ?? UIImage()
    }
}

struct MemoryCardState {
    var id: UUID
    var emojiAsString: String
}

struct MemorizeModel {

    static let allEmojis = getAllEmojis()

    static func getRandomEmoji() -> String {
        return allEmojis.randomElement() ?? "😎"
    }

    static func getRandomEmoji(count: Int)-> [String]{

        guard count > 0, count < allEmojis.count
        else {
         return allEmojis
        }

        return Array(allEmojis.shuffled()[0..<count])
    }

    static func getMemorizeCards(count:Int) -> [MemoryCardState] {
        return getRandomEmoji(count: count).map {
            MemoryCardState.init(id: UUID(), emojiAsString: $0)
            }
        }

    private static func getAllEmojis() -> [String] {
        var emojis = Set<String>()
        for i in 8400...0x1F9FF{
            if let scalar = UnicodeScalar(i), scalar.properties.isEmojiPresentation {
                emojis.insert((String(scalar)))
            }
        }
        return Array(emojis)
    }
}


struct MemorizeGame_Previews: PreviewProvider {
    static var previews: some View {
        MemorizeGame()
    }
}

