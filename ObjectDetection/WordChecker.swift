//
//  WordChecker.swift
//  ObjectDetection
//
//  Created by Andrés Aguilar on 6/15/20.
//  Copyright © 2020 Y Media Labs. All rights reserved.
//

import Foundation
import UIKit

class WordChecker {
    
    var twoDimensionalArray : [[BoardCell]] = []
    var textChecker = UITextChecker()
    var words = [String]()
    
    init(boardCellArray : [BoardCell]) {
        var counter = 0
        for _ in 0...14 {
            var currentArray : [BoardCell] = []
            while true {
                currentArray.append(boardCellArray[counter])
                counter += 1
                if counter % 15 == 0 {
                    break
                }
            }
            twoDimensionalArray.append(currentArray)
        }
    }
    
    func checkForWords() -> [String] {
        
        var foundWords = [String]()
        
        //Check Horizontal
        for row in 0...14 {
            var potentialWord = ""
            var inWord = false
            for col in 0...14 {
                let letter = twoDimensionalArray[row][col].letter
                if letter == "" || col == 14 {
                    if inWord {
                        foundWords.append(potentialWord)
                        potentialWord = ""
                    }
                    
                    inWord = false
                }
                else {
                    inWord = true
                    potentialWord += letter
                }
            }
        }
        
        //Check Vertical
        for col in 0...14 {
            var potentialWord = ""
            var inWord = false
            for row in 0...14 {
                let letter = twoDimensionalArray[row][col].letter
                if letter == "" || row == 14 {
                    if inWord {
                        foundWords.append(potentialWord)
                        potentialWord = ""
                    }
                    
                    inWord = false
                }
                else {
                    inWord = true
                    potentialWord += letter
                }
            }
        }
        
        return foundWords
    }
    
    func isEnglishWord(word : String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func isValidBoard() -> Bool {
        
        let foundWords = self.checkForWords()
        self.words = foundWords
        
        //Check if all words are in the English dictionary
        for word in foundWords {
            if self.isEnglishWord(word: word) {
                continue
            }
            else {
                return false
            }
        }
        
        //Check if all tiles are placed adjacent to other tiles
        for row in 0...14 {
            for col in 0...14 {
                
                let cell = twoDimensionalArray[row][col]
                
                if cell.letter != "" {
                    
                    //Check for adjacents
                    if row - 1 >= 0 && twoDimensionalArray[row - 1][col].letter != "" {
                        continue
                    }
                    if col + 1 < 14 && twoDimensionalArray[row][col + 1].letter != "" {
                        continue
                    }
                    if row + 1 < 14 && twoDimensionalArray[row + 1][col].letter != "" {
                        continue
                    }
                    if col - 1 >= 0 && twoDimensionalArray[row][col - 1].letter != "" {
                        continue
                    }
                    
                    print(false)
                    return false
                }
            }
        }
        
        return true
    }
}
