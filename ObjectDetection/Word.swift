//
//  Word.swift
//  ScrabbleAid
//
//  Created by Andrés Aguilar on 6/18/20.
//  Copyright © 2020 Y Media Labs. All rights reserved.
//

import Foundation

//Structure that holds information about a word in the Scrabble board
struct Word {
    var text = ""
    var start = [-1, -1]
    var end = [-1, -1]
    var valid = true
}
