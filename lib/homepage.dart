import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// design: cleaner and cuter...
// make apk and publish to github...
// learn how to publish an apk to the macapplestore lol...

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List snakePosition = [45, 65, 85, 105, 125];
  int fruitPosition = 330;
  bool gameOver = false;
  String direction = 'down';
  int boxesInARow = 20;
  int score = 0;
  bool isButtonActive = true;

  generateFruit(numberOfRows, firstColumn, lastColumn) {
    int totalBoxes = boxesInARow * boxesInARow;

    Random random = new Random();

    int newFruitPosition = random.nextInt(totalBoxes);

    while (snakePosition.contains(newFruitPosition) ||
        (newFruitPosition >= boxesInARow * (numberOfRows) - 1) ||
        (newFruitPosition <= (boxesInARow - 1)) ||
        (firstColumn.contains(newFruitPosition)) ||
        (lastColumn.contains(newFruitPosition))) {
      newFruitPosition = random.nextInt(totalBoxes);
    }

    setState(() {
      fruitPosition = newFruitPosition;
    });
  }

  startGame(numberOfRows, firstColumn, lastColumn) {
    setState(() {
      snakePosition = [45, 65, 85, 105, 125];
      fruitPosition = 330;
      direction = 'down';
      gameOver = false;
      score = 0;
    });

    const duration = const Duration(milliseconds: 300);
    Timer.periodic(duration, (Timer timer) {
      updateSnake(numberOfRows, direction, firstColumn, lastColumn);
      if (gameOver) {
        timer.cancel();
        gameOverScreen(numberOfRows, firstColumn, lastColumn);
      }
    });
  }

  void gameOverScreen(numberOfRows, firstColumn, lastColumn) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text('Score: $score'),
            actions: [
              ElevatedButton(
                  child: Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    //padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    startGame(numberOfRows, firstColumn, lastColumn);
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  updateSnake(numberOfRows, direction, firstColumn, lastColumn) {
    List snakePositionNoHead = [...snakePosition];
    snakePositionNoHead.removeLast();

    if (direction == 'down') {
      setState(() {
        if (snakePosition.last >= (boxesInARow * (numberOfRows) - 1)) {
          snakePosition.add(snakePosition.last - (numberOfRows) * boxesInARow);
          snakePosition.removeAt(0);
        } else if (snakePosition.last == fruitPosition) {
          snakePosition.add(snakePosition.last + 20);
          score++;
          generateFruit(numberOfRows, firstColumn, lastColumn);
        } else if (snakePositionNoHead.contains(snakePosition.last)) {
          gameOver = true;
        } else {
          snakePosition.add(snakePosition.last + 20);
          snakePosition.removeAt(0);
        }
      });
    } else if (direction == 'left') {
      setState(() {
        if (firstColumn.contains(snakePosition.last)) {
          snakePosition.add(snakePosition.last + 19);
          snakePosition.removeAt(0);
        } else if (snakePosition.last == fruitPosition) {
          snakePosition.add(snakePosition.last - 1);
          score++;
          generateFruit(numberOfRows, firstColumn, lastColumn);
        } else if (snakePositionNoHead.contains(snakePosition.last)) {
          gameOver = true;
        } else {
          snakePosition.add(snakePosition.last - 1);
          snakePosition.removeAt(0);
        }
      });
    } else if (direction == 'right') {
      setState(() {
        if (lastColumn.contains(snakePosition.last)) {
          snakePosition.add(snakePosition.last - 19);
          snakePosition.removeAt(0);
        } else if (snakePosition.last == fruitPosition) {
          snakePosition.add(snakePosition.last + 1);
          score++;
          generateFruit(numberOfRows, firstColumn, lastColumn);
        } else if (snakePositionNoHead.contains(snakePosition.last)) {
          gameOver = true;
        } else {
          snakePosition.add(snakePosition.last + 1);
          snakePosition.removeAt(0);
        }
      });
    } else if (direction == 'up') {
      setState(() {
        if (snakePosition.last <= (boxesInARow - 1)) {
          snakePosition
              .add(snakePosition.last + (numberOfRows - 1) * boxesInARow);
          snakePosition.removeAt(0);
        } else if (snakePosition.last == fruitPosition) {
          snakePosition.add(snakePosition.last - 20);
          score++;
          generateFruit(numberOfRows, firstColumn, lastColumn);
        } else if (snakePositionNoHead.contains(snakePosition.last)) {
          gameOver = true;
        } else {
          snakePosition.add(snakePosition.last - 20);
          snakePosition.removeAt(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height * 0.9;

    double approxWidthBox = screenWidth / boxesInARow;
    double approxNumRows = screenHeight / approxWidthBox;

    int numberOfRows = approxNumRows.floor() - 1;

    List firstColumn = [];

    for (int i = 0; i < (numberOfRows * boxesInARow); i += 20) {
      firstColumn.add(i);
    }

    List lastColumn = [];

    for (int i = 19; i < (numberOfRows * boxesInARow); i += 20) {
      lastColumn.add(i);
    }

    int totalNumberBoxes = numberOfRows * boxesInARow;

    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              flex: 9,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0 && direction != 'up') {
                    direction = 'down';
                  } else if (details.delta.dy < 0 && direction != 'down') {
                    direction = 'up';
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0 && direction != 'left') {
                    direction = 'right';
                  } else if (details.delta.dx < 0 && direction != 'right') {
                    direction = 'left';
                  }
                },
                child: Container(
                  child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: totalNumberBoxes,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: boxesInARow),
                      itemBuilder: (context, int index) {
                        if (snakePosition.contains(index)) {
                          return Padding(
                            padding: const EdgeInsets.all(3),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                          );
                        } else if (index == fruitPosition) {
                          return Padding(
                            padding: const EdgeInsets.all(3),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Container(
                                color: Colors.green,
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(3),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Container(
                                color: Colors.grey[900],
                              ),
                            ),
                          );
                        }
                      }),
                ),
              ),
            ),
            Expanded(
                child: Container(
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: isButtonActive
                        ? () {
                            startGame(numberOfRows, firstColumn, lastColumn);
                            setState(() {
                              isButtonActive = false;
                            });
                          }
                        : null,
                    child: Text('start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      //padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                      color: Colors.black,
                      child: Text(
                        '@HYDEStudios',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold, // font weight
                            color: Colors.white),
                      )),
                ],
              ),
            ))
          ],
        ));
  }
}
