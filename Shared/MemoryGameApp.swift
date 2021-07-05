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

typealias HistoryEntry = (score:Int, duration:Double, timestamp: Date)

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

    var stats:some View {
        VStack {
        HStack {
            Text("Stats").font(.headline)
        }
            List(runsHistory, id: \.timestamp) { entry in
                Text("\(entry.timestamp)")
                Text("Duration: \(entry.duration) Score: \(entry.score)")
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

#if DEBUG

struct MemorizeGame_Previews: PreviewProvider {
    static var previews: some View {
        MemorizeGame()
    }
}

 #endif
