//
//  BoardViewController.swift
//  ObjectDetection
//
//  Created by Andrés Aguilar on 5/24/20.
//  Copyright © 2020 Y Media Labs. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate {
    
    var boardCellModel = BoardCellModel()
    var boardCells = [BoardCell]()
    var cellTextArray : [String] = []
    var wordsArray : [String] = []
    
    @IBOutlet weak var boardCollectionView: UICollectionView!
    @IBOutlet weak var boardValidityLabel: UILabel!
    @IBOutlet weak var wordTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Declare the BoardViewController as the delegate and datasource of the boardCollectionView
        boardCollectionView.delegate = self
        boardCollectionView.dataSource = self
        
        //Declare the BoardViewController as the delegate and datasource of the wordTableView
        wordTableView.delegate = self
        wordTableView.dataSource = self
        
        //Put recognized tiles on board
        self.populateBoard()
        
        //Initialize WordChecker object
        let wordChecker = WordChecker(boardCellArray: boardCells)
        
        if wordChecker.isValidBoard() {
            
            //Put words on the table view (only those longer than one character)
            for word in wordChecker.checkForWords() {
                if word.count > 1 {
                    self.wordsArray.append(word)
                }
            }
            
        }
        else {
            boardValidityLabel.textColor = UIColor.red
            boardValidityLabel.text = "INVALID BOARD"
        }
    }
    
    func populateBoard() {

        //Get array of BoardCells
        boardCells = boardCellModel.getBoardCells()

        print("Array Count:", cellTextArray.count)
        print("Board cell count:", boardCells.count)
        for i in 0...cellTextArray.count - 1 {
            boardCells[i].letter = String(cellTextArray[i].prefix(1))
        }
    }
    
    //PROTOCOL STUBS:
    
    //Tells collectionView number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return boardCells.count
    }
    
    //Generates CollectionViewCell to go in CollectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Generates BoardCollectionViewCells from reusable BoardCellCollectionViewCell object
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardCell", for: indexPath) as! BoardCollectionViewCell
        
        cell.setBoardCell(boardCells[indexPath.row])
        
        //Set BoardCollectionViewCell border color and roundness
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.cornerRadius = 4;
        
        return cell
    }
    
    //Tells the BoardViewController which cell was selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func isEnglishWord(word : String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return wordsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = wordTableView.dequeueReusableCell(withIdentifier: "wordCell") as! WordTableViewCell
        
        //Get word text
        cell.wordLabel.text = wordsArray[indexPath.row]
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

