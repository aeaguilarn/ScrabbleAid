//
//  SquareModel.swift
//  Scrabble v1
//
//  Created by Andrés Aguilar on 4/7/20.
//  Copyright © 2020 Andrés Aguilar. All rights reserved.
//

import Foundation

//Class that handles board cells in the Scrabble board
class BoardCellModel {
    
    //Function that returns a list of board cells
    func getBoardCells() -> [BoardCell]{
        
        var boardCellArray = [BoardCell]()
        
        var col = 0
        var row = 0
        
        //Specify which board cells are of what color
        let redBoardCells = [0, 7, 14, 105, 119, 210, 217, 224]
        let pinkBoardCells = [16, 28, 32, 42, 48, 56, 64, 70, 196, 182, 168, 154, 208, 192, 176, 160]
        let blueBoardCells = [20, 24, 76, 80, 84, 88, 136, 140, 144, 148, 200, 204]
        let cyanBoardCells = [3, 11, 36, 38, 52, 45, 59, 92, 96, 98, 102, 108, 116, 122, 126, 128, 132, 165, 172, 179, 186, 188, 213, 221]
        
        //Build list of board cells
        for i in 0...224 {
            
            let boardCell = BoardCell()
            
            if col > 14 {
                col = col % 14
                row += 1
            }
            
            boardCell.row = row
            boardCell.column = col
            
            //Assign appropiate board cell score values
            if redBoardCells.contains(i) {
                boardCell.special = "tripple_word_score"
            }
            else if pinkBoardCells.contains(i) {
                boardCell.special = "double_word_score"
            }
            else if blueBoardCells.contains(i) {
                boardCell.special = "tripple_letter_score"
            }
            else if cyanBoardCells.contains(i) {
                boardCell.special = "double_letter_score"
            }
            else if i == 112 {
                boardCell.special = "center"
            }
            
            boardCellArray.append(boardCell)
            
            col += 1
            
        }
        
        return boardCellArray
    }
}
