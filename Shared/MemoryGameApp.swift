//
//  MemoryGameApp.swift
//  Shared
//
//  Created by Cheyo Jimenez on 6/24/21.
//

import SwiftUI

@main
struct MemoryGameApp: App {

    var body: some Scene {
        WindowGroup {
            MemorizeGame()
        }
    }
}

typealias HistoryEntry = (stats: EmojiStats, score:Int, duration:Double, timestamp: Date)

struct MemorizeGame: View {

    @State var runsHistory = [HistoryEntry]()

    var game:some View {
        VStack {
        HStack {
            Text("Memory Game").font(.headline)
        }
         GeometryReader{  geometry in
                MemorizeGrid(runsHistory: $runsHistory)
            }
        }
    }

    var puzzle: some View {
        VStack {
        HStack {
            Text("Memory Game").font(.headline)
        }
            PuzzleGrid()
        }
    }

     func formatCardStats(_ cards: EmojiStats, upToCount:Int = 4) -> String {
        let sorted = cards.map {keyValue in (key: keyValue.key.emojiAsString, value: keyValue.value) }.sorted {left, right in left.value > right.value}
        var count = 0
        var valueToReturn = "|"
        for each in sorted {
            defer {
                count += 1
            }
            if (count >= upToCount) {
                break;
            }

            valueToReturn += " \(each.key):\(each.value) |"
        }
        return valueToReturn

    }

    var stats:some View {
        VStack {
        HStack {
            Text("Stats").font(.headline)
        }
            List(runsHistory, id: \.timestamp) { entry in
                Text("\(entry.timestamp)")
                Text("Duration: \(entry.duration) Score: \(entry.score)")
                Text("Stats: \(formatCardStats(entry.stats))")
                Spacer()
            }
        }
    }


    var body: some View {

        TabView
        {
            // First Tab
            game.tabItem {
                Image(uiImage: UIImage(systemName: "gamecontroller")!)
                    Text("Match")
                }

            //Tab
            puzzle.tabItem {
                Image(uiImage: UIImage(systemName: "gamecontroller")!)
                    Text("Puzzle")
                }

            // Next Tab
            stats.tabItem{
                Image(uiImage: UIImage(systemName: "heart")!)
                    Text("Stats")
            }
        }
    }
}

#if DEBUG

struct MemorizeGame_Previews: PreviewProvider {
    static var previews: some View {
        MemorizeGame()
    }
}

 #endif
