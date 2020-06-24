# ScrabbleAid
Scrabble Aid is an iOS application that uses the power of machine learning to check the validity of the state of a particular Scrabble board. The application utilizes the Tensorflow Lite framework to determine the position of a Scrabble board and its tiles when captured by the device's camera, and it uses the MLKit framework to recognize the letter each tile on the board represents. 

Finally, the application allows the user to visualize the traversal through the Scrabble board performed for its validation, as well as the location of particular words on the board. 

## Getting Started
Follow these instructions to build and run the application on you iOS device. 

### Prerequisites

1. Xcode

2. CocoaPods

3. iOS device (preferably iPhone XR)

### Building the Scrabble Aid App on Xcode

1. Clone or download the project into your computer.

2. Install the pods to generate the application workspace file. In the terminal, go to the directory where you cloned or downloaded the project, and run the command **pod install**. This will generate a file called **ScrabbleAid.xcworkspace**.

3. Open the **ScrabbleAid.xcworkspace** file with **Xcode**.

4. Modify the bundle identifier and select the development team in **General->Signing**.

5. Build and run the app in **Xcode**. Note that the app can't be ran on the Xcode simulator, it must be ran on a real iOS device. (This application was made to run on an iPhone XR).

### Running Scrabble Aid on Your Device

1. Once the app is installed, tap the app icon on you homescreen to open it.  

2. You will need a Scrabble board to detect. Unfortunately, for the app to work properly, you will need to use the exact version of the Scrabble board that the application was built to work with. You may print the image below and use that as your Scrabble board.

<img src="https://github.com/aeaguilarn/ScrabbleAid/blob/master/ScrabbleBoard.jpg" width="400">

3. After scanning the board, comfirm the center tile of the board was accurately detected. Make sure the entire tile fits on the frame. If detection unsuccessful, you may scan the board again.

4. Finally, select which searching algorithm you would like to use to validate the Scrabble board. For a Scrabble board to be valid, there are two criteria that must be met. First, there must be a path (of horizontally and vertically adjacent tiles) starting from the center tile to every tile placed on the board. Second, tiles on the board (from left to right or top to bottom)  must represent words contained in the English dictionary.

### Built With

* Python

* Swift

* Tensorflow

* MLKit

### Contributing

All contributions or feedback are welcome!





