//
//  KeyModel.swift
//  Scrabble v1
//
//  Created by Andrés Aguilar on 4/12/20.
//  Copyright © 2020 Andrés Aguilar. All rights reserved.
//

import Foundation

class TileModel {
    
    func getTiles() -> [Tile]{
        
        var tilesArray = [Tile]()
        
        for _ in 0...6 {
            
            let tile = Tile()
            
            tile.letter = "B"
            
            tilesArray.append(tile)
        }
        
        return tilesArray
    }
}
