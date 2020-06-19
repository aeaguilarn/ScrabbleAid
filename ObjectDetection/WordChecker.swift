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
    var words = [Word]()
    var tileCount = 0
    
    init(boardCellArray : [BoardCell]) {
        var counter = 0
        for _ in 0...14 {
            var currentArray : [BoardCell] = []
            while true {
                if boardCellArray[counter].letter != "" {
                    self.tileCount += 1
                }
                currentArray.append(boardCellArray[counter])
                counter += 1
                if counter % 15 == 0 {
                    break
                }
            }
            twoDimensionalArray.append(currentArray)
        }
    }
    
    func checkForWords() -> [Word] {
        
        var foundWords = [Word]()
        
        //Check Horizontal
        for row in 0...14 {
            var word = Word()
            var inWord = false
            for col in 0...14 {
                let letter = twoDimensionalArray[row][col].letter
                if letter == "" || col == 14 {
                    if inWord {
                        
                        if col == 14{
                            word.end = [row, col]
                        }
                        else {
                            word.end = [row, col - 1]
                        }
                        
                        foundWords.append(word)
                        word = Word()
                    }
                    
                    inWord = false
                }
                else {
                    
                    if inWord == false {
                        word.start = [row, col]
                    }
                    inWord = true
                    word.text += letter
                }
            }
        }
        
        //Check Vertical
        for col in 0...14 {
            var word = Word()
            var inWord = false
            for row in 0...14 {
                let letter = twoDimensionalArray[row][col].letter
                if letter == "" || row == 14 {
                    if inWord {
                        
                        if row == 14{
                            word.end = [row, col]
                        }
                        else {
                            word.end = [row - 1, col]
                        }
                        
                        foundWords.append(word)
                        word = Word()
                    }
                    
                    inWord = false
                }
                else {
                    if inWord == false {
                        word.start = [row, col]
                    }
                    inWord = true
                    word.text += letter
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
            if self.isEnglishWord(word: word.text.lowercased()) {
                continue
            }
            else {
                return false
            }
        }
        
        return true
    }
    
    func getTwoDimensinalArray() -> [[BoardCell]]{
        return twoDimensionalArray
    }
}
