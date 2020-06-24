# ScrabbleAid
Scrabble Aid is an iOS application that uses the power of machine learning to check the validity of the state of a particular Scrabble board. The application utilizes the Tensorflow Lite framework to determine the position of a Scrabble board and its tiles when captured by the device's camera, and it uses the MLKit framework to recognize the letter each tile on the board represents. 

Finally, the application allows the user to visualize the traversal through the Scrabble board performed for its validation, as well as the location of particular words on the board. 

## Getting Started
Follow these instructions to build and run the application on you iOS device. 

### Prerequisites

1. Xcode

2. CocoaPods

3. iOS device (preferably iPhone XR)

### Building the Scrabble Aid application

1. Clone or download the project into your computer.

2. Install the pods to generate the application workspace file. In the terminal, go to the directory where you cloned or downloaded the project, and run the command **pod install**. This will generate a file called **ScrabbleAid.xcworkspace**.

3. Open the **ScrabbleAid.xcworkspace** file with **Xcode**.

4. Modify the bundle identifier and select the development team in **General->Signing**.

5. Build and run the app in **Xcode**. Note that the app can't be ran on the Xcode simulator, it must be ran on a real iOS device. (This application was made to run on an iPhone XR).





