//
//  BoardCollectionViewCell.swift
//  ObjectDetection
//
//  Created by Andrés Aguilar on 5/24/20.
//  Copyright © 2020 Y Media Labs. All rights reserved.
//

import UIKit

class BoardCollectionViewCell: UICollectionViewCell {
    
    var boardCell:BoardCell?
    
    @IBOutlet weak var letterLabel: UILabel!
    
    func setBoardCell(_ boardCell: BoardCell) {
            
            self.letterLabel.text = boardCell.letter
            //Assign BoardCell passed in as argument from BoardViewController to this BoardCollectionViewCell's BoardCell
            self.boardCell = boardCell
            
            //Assign color of BoardCell
            if self.boardCell?.special == "tripple_word_score" {
                self.backgroundColor = UIColor.init(red: (255.0 / 255.0), green: (77.0 / 255.0), blue: (103.0 / 255.0), alpha: 1.0)
            }
            else if self.boardCell?.special == "double_word_score" {
                self.backgroundColor = UIColor.init(red: (243.0 / 255.0), green: (178.0 / 255.0), blue: (219.0 / 255.0), alpha: 1.0)
            }
            else if self.boardCell?.special == "tripple_letter_score" {
                self.backgroundColor = UIColor.init(red: (0.0 / 255.0), green: (151.0 / 255.0), blue: (206.0 / 255.0), alpha: 1.0)
            }
            else if self.boardCell?.special == "double_letter_score" {
                self.backgroundColor = UIColor.init(red: (111.0 / 255.0), green: (207.0 / 255.0), blue: (235.0 / 255.0), alpha: 1.0)
            }
            else if self.boardCell?.special == "center" {
                self.backgroundColor = UIColor.init(red: (230.0 / 255.0), green: (230.0 / 255.0), blue: (230.0 / 255.0), alpha: 1.0)
            }
            else {
                self.backgroundColor = UIColor.init(red: (230.0 / 255.0), green: (230.0 / 255.0), blue: (230.0 / 255.0), alpha: 1.0)
            }
        }
}
