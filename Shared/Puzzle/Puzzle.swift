//
//  Puzzle.swift
//  MemoryGame
//
//  Created by Cheyo Jimenez on 7/12/21.
//

import SwiftUI


struct PuzzleSlot {
    
}

class PuzzleModel: ObservableObject {
    @Published var grid = [PuzzleSlot]()
}

