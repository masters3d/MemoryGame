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

#if DEBUG

struct MemorizeGame_Previews: PreviewProvider {
    static var previews: some View {
        MemorizeGame()
    }
}

 #endif
