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
    var wordsArray : [Word] = []
    var selectedTableWord : Word = Word()
    lazy var wordChecker = WordChecker(boardCellArray: boardCells)
    var timer : Timer?
    
    @IBOutlet weak var boardCollectionView: UICollectionView!
    @IBOutlet weak var boardValidityLabel: UILabel!
    @IBOutlet weak var wordTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var validationButton: UIButton!
    @IBOutlet weak var validationPromptLabel: UILabel!
    @IBOutlet weak var rescanButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicatorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
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
        
        //Hide table view, board validity label, activity indicator and activity indicator label
        //These will show after the user hits the validation button
        self.wordTableView.isHidden = true
        self.boardValidityLabel.isHidden = true
        self.activityIndicatorLabel.isHidden = true
        self.activityIndicator.isHidden = true
    }
    
 //Function that validates board, using the traversal algorithm seleceted by the user and verifying each word is in the English dictionary
    //Called when user hits the validation button
    @IBAction func traverseBoardButton(_ sender: Any) {
        
        self.titleLabel.isHidden = true
        self.rescanButton.isHidden = true
        self.validationPromptLabel.isHidden = true
        self.segmentedControl.isHidden = true
        self.validationButton.isHidden = true
        
        self.activityIndicatorLabel.isHidden = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        //Traverse the board with the user's selected traversal algorithm
        if self.segmentedControl.selectedSegmentIndex == 0 {
            
            self.activityIndicatorLabel.text = "Performing Depth-First Search Traversal..."
        
            depthFirstSearchValidation { (valid) in
                print("valid assigned")
                self.activityIndicatorLabel.isHidden = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.finishValidation(validTilePositions: valid)
            }
        }
        else {
            
            self.activityIndicatorLabel.text = "Performing Breadth-First Search Traversal..."
            
            breadthFirstSearchValidation { (valid) in
                print("valid assigned")
                self.activityIndicatorLabel.isHidden = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.finishValidation(validTilePositions: valid)
            }
        }
    }
    
    func finishValidation(validTilePositions : Bool) {
        //If tiles are placed on the board in a valid way, verify is the words themselves are valid
        if validTilePositions {

            //Verify if every word in the board is in the English dictionary
            if wordChecker.hasValidWords() {

                //Put words on the table view (only those longer than one character)
                for word in wordChecker.checkForWords() {
                    if word.text.count > 1 {
                        self.wordsArray.append(word)
                    }
                }
                
                //Reload the table view, to display the words
                wordTableView.reloadData()
            }
            else {
                //Let the user know that the board is in an invalid state
                //Leave table view blank
                boardValidityLabel.textColor = UIColor.red
                boardValidityLabel.text = "INVALID BOARD"
            }
        }
        else {
            //Let the user know that the board is in an invalid state
            //Leave table view blank
            boardValidityLabel.textColor = UIColor.red
            boardValidityLabel.text = "INVALID BOARD"
        }
        
        //Show table view, as well as board state (valid or invalid)
        self.wordTableView.isHidden = false
        self.wordTableView.frame.origin.y = 550
        
        //Allow the user to rescan the board if he or she desires
        self.rescanButton.frame.origin.y = 790
        self.rescanButton.frame.origin.x = 146
        self.rescanButton.isHidden = false
        
        self.boardValidityLabel.isHidden = false
        self.titleLabel.isHidden = false
        self.titleLabel.text = "Words:"
    }
    
    //Function that sets each cell's value to the apropriate letter
    func populateBoard() {

        //Get array of BoardCells
        boardCells = boardCellModel.getBoardCells()

        for i in 0...cellTextArray.count - 1 {
            boardCells[i].letter = String(cellTextArray[i].prefix(1))
            boardCells[i].column = i % 15
            boardCells[i].row = Int(i / 15)
            boardCells[i].cellNum = i
        }
        
    }
    
    //PROTOCOL STUBS:
    
    //Function that specifies the size of collection view to be built
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return boardCells.count
    }
    
    //Function that builds a collection view from a list of Scrabble board cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Generates BoardCollectionViewCells from reusable BoardCellCollectionViewCell object
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardCell", for: indexPath) as! BoardCollectionViewCell
        
        cell.setBoardCell(boardCells[indexPath.row])
        
        //Set BoardCollectionViewCell border color and roundness
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.cornerRadius = 4;
        
        return cell
    }
    
    //Function called whenever a cell in the BoardCollectionView is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    //Function that specifies the size of table view to be built
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return wordsArray.count
    }
    
    //Function that builds a table view from a list of words
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = wordTableView.dequeueReusableCell(withIdentifier: "wordCell") as! WordTableViewCell
        
        //Gets word to put in the table view
        cell.word = wordsArray[indexPath.row]
        cell.wordLabel.text = cell.word.text
        
        return cell
    }
    
    //Function that highlights tiles in the Scrabble board that represent the selected word in the Table View
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let word = wordsArray[indexPath.row]
        
        //Un-Highlight previously selected word
        if selectedTableWord.text != "" {
            
            //Traverse through every tile that represents previously selected word
            for row in selectedTableWord.start[0]...selectedTableWord.end[0] {
                for col in selectedTableWord.start[1]...selectedTableWord.end[1] {
                    
                    let index = IndexPath(row: (row * 15) + col, section: 0)
                    let currentCell = boardCollectionView.cellForItem(at: index) as! BoardCollectionViewCell
                    
                    //Un-highlight tile
                    currentCell.highlightCell(value: false)
                }
            }
            
        }
        
        //Hightlight new seleceted word
        //Traverse through every tile that represents previously selected word
        for row in word.start[0]...word.end[0] {
            for col in word.start[1]...word.end[1] {
                
                let index = IndexPath(row: (row * 15) + col, section: 0)
                let currentCell = boardCollectionView.cellForItem(at: index) as! BoardCollectionViewCell
                
                //Highlight tile
                currentCell.highlightCell(value: true)
            }
        }
        
        //Sets what the new selected word is
        selectedTableWord = word
    }
    

    
    //Function that checks if there is a path from the center tile to every tile in the board
    //using the Detph-First Serach traversal algorithm
    func depthFirstSearchValidation(completion: @escaping (Bool) -> Void) {
        
        print("DFS")
        
        //Board cell matrix to traverse
        let matrix = self.wordChecker.getTwoDimensinalArray()
        
        //If center is empty, then board is invalid
        if matrix[7][7].letter == "" {
            return completion(false)
        }
        
        //Stack to assist in depth-first search
        var stack : [BoardCell] = [matrix[7][7]]
        var visited : [Int] = []
        
        //Depth-First Search
        var finished = false
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in

            if stack.count == 0 {
                finished = true
                timer.invalidate() // terminate timer loop
            }
            
            if !finished {
                
                let node = stack.popLast()!
                
                //Check if the cell has been already visited, mark visited if not
                if !visited.contains(node.cellNum) {
                    
                    visited.append(node.cellNum)
                    
                    //Select collection view cell
                    let index = IndexPath(row: node.cellNum, section: 0)
                    let currentCell = self.boardCollectionView.cellForItem(at: index) as! BoardCollectionViewCell
                    
                    //Highlight Cell
                    currentCell.highlightCell(value: true, color: UIColor.green)
                    
                    //Append neighbors of current cell to stack
                    for child in self.getCellNeighbors(matrix, node) {
                        if child.letter != "" {
                            stack.append(child)
                        }
                    }
                }
            }
            else {
                
                //Un-highlight cells
                for cellNum in visited {
                    let index = IndexPath(row: cellNum, section: 0)
                    let currentCell = self.boardCollectionView.cellForItem(at: index) as! BoardCollectionViewCell
                    currentCell.highlightCell(value: false)
                }
                
                //Return true if all tiles in board where visited.
                //For a cell to be visited, there must have been a path from the center tile to it
                if visited.count == self.wordChecker.tileCount {
                    return completion(true)
                }
                else {
                    return completion(false)
                }
            }
        }
    }
    
    //Function that checks if there is a path from the center tile to every tile in the board
    //using the Breadth-First Serach traversal algorithm
    func breadthFirstSearchValidation(completion: @escaping (Bool) -> Void) {
        
        print("BFS")
        
        //Board cell matrix to traverse
        let matrix = self.wordChecker.getTwoDimensinalArray()
        
        //If center is empty, then board is invalid
        if matrix[7][7].letter == "" {
            return completion(false)
        }
        
        //Queue to assist in bread-first search
        var queue : [BoardCell] = [matrix[7][7]]
        var visited : [Int] = []
        
        //Depth-First Search
        var finished = false
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in

            if queue.count == 0 {
                finished = true
                timer.invalidate() // terminate timer loop
            }
            
            if !finished {
                
                let node = queue.remove(at: 0)
                
                //Check if the cell has been already visited, mark visited if not
                if !visited.contains(node.cellNum) {
                    
                    visited.append(node.cellNum)
                    
                    //Select collection view cell
                    let index = IndexPath(row: node.cellNum, section: 0)
                    let currentCell = self.boardCollectionView.cellForItem(at: index) as! BoardCollectionViewCell
                    
                    //Highlight Cell
                    currentCell.highlightCell(value: true, color: UIColor.green)
                    
                    //Append neighbors of current cell to stack
                    for child in self.getCellNeighbors(matrix, node) {
                        if child.letter != "" {
                            queue.append(child)
                        }
                    }
                }
            }
            else {
                
                //Un-highlight cells
                for cellNum in visited {
                    let index = IndexPath(row: cellNum, section: 0)
                    let currentCell = self.boardCollectionView.cellForItem(at: index) as! BoardCollectionViewCell
                    currentCell.highlightCell(value: false)
                }
                
                //Return true if all tiles in board where visited.
                //For a cell to be visited, there must have been a path from the center tile to it
                if visited.count == self.wordChecker.tileCount {
                    return completion(true)
                }
                else {
                    return completion(false)
                }
            }
        }
    }
    
    //Function that returns a list of the neighboring cells of a particular cell in the scrabble board
    func getCellNeighbors(_ matrix: [[BoardCell]], _ node: BoardCell) -> [BoardCell] {
        
        var neighbors : [BoardCell] = []
        let row = node.row
        let col = node.column
        
        //Checks cell above
        if row - 1 >= 0 {
            neighbors.append(matrix[row - 1][col])
        }
        //Checks cell right
        if col + 1 < 15 {
            neighbors.append(matrix[row][col + 1])
        }
        //Checks cell below
        if row + 1 < 15 {
            neighbors.append(matrix[row + 1][col])
        }
        //Checks cell to the left
        if col - 1 >= 0 {
            neighbors.append(matrix[row][col - 1])
        }
        
        return neighbors
    }

}

