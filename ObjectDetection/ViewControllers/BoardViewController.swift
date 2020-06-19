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
    
    @IBOutlet weak var boardCollectionView: UICollectionView!
    @IBOutlet weak var boardValidityLabel: UILabel!
    @IBOutlet weak var wordTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var validationButton: UIButton!
    @IBOutlet weak var validationPromptLabel: UILabel!
    @IBOutlet weak var rescanButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func traverseBoardButton(_ sender: Any) {
        self.segmentedControl.isHidden = true
        self.validationButton.isHidden = true
        
        if self.segmentedControl.selectedSegmentIndex == 0 {
            print(depthFirstSearchValidation())
        }
        else {
            print(breadthFirstSearchValidation())
        }
        
        self.validationPromptLabel.isHidden = true
        self.wordTableView.isHidden = false
        self.wordTableView.frame.origin.y = 550
        
        self.rescanButton.frame.origin.y = 790
        self.rescanButton.frame.origin.x = 146
        
        self.boardValidityLabel.isHidden = false
        self.titleLabel.text = "Words:"
    }
    
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
        
        self.wordTableView.isHidden = true
        self.boardValidityLabel.isHidden = true
        
        //Initialize WordChecker object
        //self.wordChecker = WordChecker(boardCellArray: boardCells)
        
        //Verify if every word in the board is in the English dictionary
        if wordChecker.isValidBoard() {
            
            //Put words on the table view (only those longer than one character)
            for word in wordChecker.checkForWords() {
                if word.text.count > 1 {
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

        for i in 0...cellTextArray.count - 1 {
            boardCells[i].letter = String(cellTextArray[i].prefix(1))
            boardCells[i].column = i % 15
            boardCells[i].row = Int(i / 15)
            boardCells[i].cellNum = i
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return wordsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = wordTableView.dequeueReusableCell(withIdentifier: "wordCell") as! WordTableViewCell
        
        //Get word
        cell.word = wordsArray[indexPath.row]
        cell.wordLabel.text = cell.word.text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let word = wordsArray[indexPath.row]
        
        //Un-Highlight previously selected word
        if selectedTableWord.text != "" {
            
            for row in selectedTableWord.start[0]...selectedTableWord.end[0] {
                for col in selectedTableWord.start[1]...selectedTableWord.end[1] {
                    
                    let index = IndexPath(row: (row * 15) + col, section: 0)
                    let currentCell = boardCollectionView.cellForItem(at: index) as! BoardCollectionViewCell
                    
                    currentCell.highlightCell(value: false)
                }
            }
            
        }
        
        //Hightlight new seleceted word
        for row in word.start[0]...word.end[0] {
            for col in word.start[1]...word.end[1] {
                
                let index = IndexPath(row: (row * 15) + col, section: 0)
                let currentCell = boardCollectionView.cellForItem(at: index) as! BoardCollectionViewCell
                
                currentCell.highlightCell(value: true)
            }
        }
        
        selectedTableWord = word
    }
    
    func depthFirstSearchValidation() -> Bool{
        
        print("DFS")
        
        let matrix = self.wordChecker.getTwoDimensinalArray()
        var stack : [BoardCell] = [matrix[7][7]]
        var visited : [Int] = []
        
        while stack.count > 0 {
            let node = stack.popLast()!
            
            //Check if the cell has been already visited, mark visited if not
            if visited.contains(node.cellNum) {
                continue
            }
            else {
                visited.append(node.cellNum)
            }
            
            //Highlight Cell
            let index = IndexPath(row: node.cellNum, section: 0)
            let currentCell = boardCollectionView.cellForItem(at: index) as! BoardCollectionViewCell
            currentCell.highlightCell(value: true)
            
            do {
                sleep(1)
            }
            
            for child in self.getCellNeighbors(matrix, node) {
                if child.letter != "" {
                    stack.append(child)
                }
            }
        }
        
        if visited.count == self.wordChecker.tileCount {
            return true
        }
        else {
            return false
        }
        
    }
    
    func breadthFirstSearchValidation() -> Bool {
        
        print("BFS")
        
        let matrix = self.wordChecker.getTwoDimensinalArray()
        
        if matrix[7][7].letter == "" {
            return false
        }
        
        var queue : [BoardCell] = [matrix[7][7]]
        var visited : [Int] = []
        
        while queue.count > 0 {
            let node = queue.remove(at: 0)
            
            //Check if the cell has been already visited, mark visited if not
            if visited.contains(node.cellNum) {
                continue
            }
            else {
                visited.append(node.cellNum)
            }
            
            //Highlight Cell
            let index = IndexPath(row: node.cellNum, section: 0)
            let currentCell = boardCollectionView.cellForItem(at: index) as! BoardCollectionViewCell
            currentCell.highlightCell(value: true)
            
            do {
                sleep(1)
            }
            
            for child in self.getCellNeighbors(matrix, node) {
                if child.letter != "" {
                    queue.append(child)
                }
            }
        }
        
        if visited.count == self.wordChecker.tileCount {
            return true
        }
        else {
            return false
        }
    }
    
    func getCellNeighbors(_ matrix: [[BoardCell]], _ node: BoardCell) -> [BoardCell] {
        
        var neighbors : [BoardCell] = []
        let row = node.row
        let col = node.column
        
        if row - 1 >= 0 {
            neighbors.append(matrix[row - 1][col])
        }
        if col + 1 < 15 {
            neighbors.append(matrix[row][col + 1])
        }
        if row + 1 < 15 {
            neighbors.append(matrix[row + 1][col])
        }
        if col - 1 >= 0 {
            neighbors.append(matrix[row][col - 1])
        }
        
        return neighbors
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

