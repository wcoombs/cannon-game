/************************
 William Coombs
 COMP 1010 A01
 Assignment 3
 Question 2 - Cannon Game
 ************************/

/************************************************
 Create a cannon game between the user and an AI.
 ************************************************/


/****************
 GLOBAL VARIABLES
 ****************/

// canvas properties
final int CANVAS_SIZE = 500;
final int BG_COLOR = 255;
final int PLAYER_COLOR = 128;
final int ENEMY_COLOR = 0;

// booleans
boolean gameOver = false;
boolean enemyAlive = false;
boolean enemyCannonBall = false;
boolean playerCannonBall = false;
boolean ballHitPad = false;

// game over properties
final String GAME_OVER_TEXT = "Game Over";
final int GAME_OVER_COLOR = #ff0000; // draws the Game Over text in red (just for added flavor)
final int GAME_OVER_SIZE = 30;
final int GAME_OVER_X = CANVAS_SIZE/2-80; // positions the text roughly in the center of the screen x
final int GAME_OVER_Y = CANVAS_SIZE/2; // positions the text in the center of the screen y

// new game properties
final String NEW_GAME_TEXT = "Press the \'Enter\' Key to begin a New Game";
final int NEW_GAME_COLOR = 0;
final int NEW_GAME_SIZE = 15;
final int NEW_GAME_X = CANVAS_SIZE/2 - 150;
final int NEW_GAME_Y = CANVAS_SIZE/2 + NEW_GAME_SIZE*2;

// score properties
final String SCORE_TEXT = "Score: ";
int scoreNumber = 0;
final int SCORE_TEXT_SIZE = 20;
final int SCORE_TEXT_COLOR = 0;
final int SCORE_X = 0;
final int SCORE_Y = SCORE_TEXT_SIZE; // ensures the text appears in the upper-left corner, regardless of size

// cannon properties
final int PAD_WIDTH = 30;
final int PAD_HEIGHT = 50;
final int CANNON_LENGTH = 30;
float playerCannonDirection; // the direction that the player's cannon gun faces
float enemyCannonDirection; // the direction that the enemy's cannon gun faces
final int PLAYER_POSITION_X = 20; // fixes the player's position on the far left side of the screen
int enemyPositionX; // places the enemy's position somewhere on the right side of the screen, defined later on
final int ENEMY_LEFT_BOUNDARY = CANVAS_SIZE/2+PAD_WIDTH; // prevents the enemy from regenerating left of center screen
final int ENEMY_RIGHT_BOUNDARY = CANVAS_SIZE-PAD_WIDTH; // prevents the enemy from regenerating past screen right edge
final float ENEMY_CANNON_UP_BOUNDARY = 3*PI/2; // prevents the enemy's cannon from firing backwards
final float ENEMY_CANNON_LEFT_BOUNDARY = PI; // prevents the enemy's cannon from firing down with little x-direction

// cannonball properties
final float BALL_SPEED = 10; // the speed of the ball, used as the radius in later calculations
final float GRAVITY = 0.153;
final int BALL_SIZE = 30;
final int BALL_RADIUS = BALL_SIZE/2;
float playerBallX; // the x-coordinate of the player's cannonball
float playerBallY; // the y-coordinate of the player's cannonball
float playerBallSpeedX;
float playerBallSpeedY;
float enemyBallX; // the x-coordinate of the enemy's cannonball
float enemyBallY; // the y-coordinate of the enemy's cannonball
float enemyBallSpeedX;
float enemyBallSpeedY;


/*********
 FUNCTIONS
 *********/

// function that updates the enemy and all their corresponding functions
void updateEnemy()
{
  if (!enemyAlive) // if the enemy is dead
  {
    // place the enemy in a random spot on the right side of the screen
    enemyPositionX = (int)random(ENEMY_LEFT_BOUNDARY, ENEMY_RIGHT_BOUNDARY);
    enemyAlive = true;
  }

  if (!enemyCannonBall) // if the enemy's cannonball is not alive
  {
    // calculate the angle of the enemy cannon's gun, between two boundary values
    enemyCannonDirection = randomRange(ENEMY_CANNON_LEFT_BOUNDARY, ENEMY_CANNON_UP_BOUNDARY);

    // fire a cannonball from the cannon's base at the top of the pad
    enemyBallX = enemyPositionX+PAD_WIDTH/2;
    enemyBallY = height-PAD_HEIGHT;

    // calculate the speed of the ball based on the angle of the x and y positions of the cannon
    enemyBallSpeedX = getXComponent(enemyCannonDirection, BALL_SPEED);
    enemyBallSpeedY = getYComponent(enemyCannonDirection, BALL_SPEED);
    enemyCannonBall = true;
  } else if (enemyCannonBall) // otherwise, if the enemy's cannonball is alive
  {
    // update the cannonball based on it's speed
    enemyBallX += enemyBallSpeedX;
    enemyBallY += enemyBallSpeedY;
    enemyBallSpeedY += GRAVITY; // adds gravity to the y-component of the ball, so that it falls down

    // detect if the ball hit's the player's cannon pad
    if (ballHitPad(enemyBallX, enemyBallY, PLAYER_POSITION_X)) // if ballHitPad is true
    {
      gameOver = true;
    }

    // detect if the ball's edge hits the left edge or the bottom of the screen
    if (enemyBallX-BALL_RADIUS <= 0 || enemyBallY+BALL_RADIUS >= height)
    {
      enemyCannonBall = false;
    } else {
      drawCannonBall(enemyBallX, enemyBallY, ENEMY_COLOR);
    }
  }
}


// function that updates the player and all their corresponding functions
void updatePlayer()
{
  // calculate the angle of the player's cannon gun
  playerCannonDirection = calcAngle(PLAYER_POSITION_X+PAD_WIDTH/2, height-PAD_HEIGHT/2, mouseX, mouseY);

  if (mousePressed && !playerCannonBall) // if the player's cannonball is not alive and the mouse is pressed
  {
    // fire a cannonball from the cannon's base at the top of the pad
    playerBallX = PLAYER_POSITION_X+PAD_WIDTH/2;
    playerBallY = height-PAD_HEIGHT;

    // calculate the speed of the ball based on the angle of the x and y positions of the cannon
    playerBallSpeedX = getXComponent(playerCannonDirection, BALL_SPEED);
    playerBallSpeedY = getYComponent(playerCannonDirection, BALL_SPEED);
    playerCannonBall = true;
  } else if (playerCannonBall) // otherwise, if the cannonball is alive
  {
    // update the cannonball based on it's speed
    playerBallX += playerBallSpeedX;
    playerBallY += playerBallSpeedY;
    playerBallSpeedY += GRAVITY; // adds gravity to the y-component of the ball, so that it falls down

    // detect if the ball hits the enemy's cannon pad
    if (ballHitPad(playerBallX, playerBallY, enemyPositionX)) // if ballHitPad is true
    {
      enemyAlive = false;
      scoreNumber++;
      playerCannonBall = false;
    }

    // detect if the ball's edge hits the right edge or bottom of the screen or, just in case it happens, the left edge of the screen
    if (playerBallX+BALL_RADIUS >= width || playerBallY+BALL_RADIUS >= height || playerBallX-BALL_RADIUS <= 0)
    {
      playerCannonBall = false;
    } else {
      drawCannonBall(playerBallX, playerBallY, PLAYER_COLOR);
    }
  }
}


// function that detects if a player or enemy's cannon pad is hit
boolean ballHitPad(float x, float y, float cannonCenter)
{
  boolean hit = false; // the initial value of the boolean, made true only if the following happens

  if (x+BALL_RADIUS >= cannonCenter &&// if the ball's right edge is to the cannon pad's left AND
  x-BALL_RADIUS <= cannonCenter+PAD_WIDTH && // if the ball's left edge is to the cannon pad's right AND
  y+BALL_RADIUS >= height-PAD_HEIGHT) // if the ball's bottom is below the cannon pad
  {
    hit = true;
  }
  return hit;
}


// function that takes an angle and radius and calculates the x of the end point
float getXComponent(float angle, float radius)
{
  float x = cos(angle)*radius;
  return x;
}


// function that takes an angle and radius and calculates the y of the end point
float getYComponent(float angle, float radius)
{
  float y = sin(angle)*radius;
  return y;
}


// function that generates a random number between the given min and max
float randomRange(float min, float max)
{
  float number = random(min, max);
  return number;
}


// function that calculates the angle between two points and returns said angle
float calcAngle(float fromX, float fromY, float toX, float toY)
{
  float angle = atan2(toY-fromY, toX-fromX);
  return angle;
}


// function that draws the cannonball, invoked by both the player and the enemy
void drawCannonBall(float x, float y, int cannonBallColor)
{
  stroke(cannonBallColor);
  fill(cannonBallColor);
  ellipse(x, y, BALL_SIZE, BALL_SIZE);
}


// function that draws the cannon pad, invoked by both the player and the enemy
void drawCannon(int positionX, int positionY, float cannonAngle, int cannonColor)
{
  stroke(cannonColor);
  fill(cannonColor);
  rect(positionX, positionY, PAD_WIDTH, PAD_HEIGHT);
  drawLine(positionX+PAD_WIDTH/2, height-PAD_HEIGHT, cannonAngle, CANNON_LENGTH);
}


// function that draws the cannon gun, invoked by both the player and the enemy
void drawLine(float padX, float padY, float angle, float cannonLength)
{
  float x = getXComponent(angle, cannonLength);
  float y = getYComponent(angle, cannonLength);
  line(padX+x, padY+y, padX, padY);
}


// function that draws the game over and new game messages
void drawGameOverAndNewGameMessages(String message, int x, int y, int messageSize, int messageColor)
{
  fill(messageColor);
  textSize(messageSize);
  text(message, x, y);
}


// function that allows the player to begin a new game, without needing to restart the program
void newGame()
{
  gameOver = false;
  enemyAlive = false;
  enemyCannonBall = false;
  playerCannonBall = false;
  ballHitPad = false;
  scoreNumber = 0;
}


// function that keeps track of and draws the player's score
void drawScore()
{
  String score = SCORE_TEXT + scoreNumber;
  textSize(SCORE_TEXT_SIZE);
  stroke(SCORE_TEXT_COLOR);
  fill(SCORE_TEXT_COLOR);
  text(score, SCORE_X, SCORE_Y);
}


/*********************
 SETUP AND DRAW BLOCKS
 *********************/

void setup()
{
  size(CANVAS_SIZE, CANVAS_SIZE);
}


void draw()
{
  background(BG_COLOR);

  if (gameOver)
  {
    // draw the game over and new game messages by invoking the corresponding functions
    drawGameOverAndNewGameMessages(GAME_OVER_TEXT, GAME_OVER_X, GAME_OVER_Y, GAME_OVER_SIZE, GAME_OVER_COLOR); // draws Game Over message
    drawGameOverAndNewGameMessages(NEW_GAME_TEXT, NEW_GAME_X, NEW_GAME_Y, NEW_GAME_SIZE, NEW_GAME_COLOR); // draws New Game message

    /*****************************************************************************************************
     In order to start a new game without needing to close the program and rerun it, the player is instead
     notified that if they press the enter key a new game will begin. If enter is pressed, the newGame
     function is invoked, where all the program's booleans will be reset to their initial values (which
     are all false, as defined in the global variables section) and the player's score is reset to 0.
     *****************************************************************************************************/

    if (keyPressed)
    {
      if (key == ENTER)
      {
        newGame();
      }
    }
  } else { // if the game is not over
    // update the enemy and all their components by invoking the corresponding function
    updateEnemy();

    // update the player and all their components by invoking the corresponding function
    updatePlayer();
  }

  // draw the score by invoking the corresponding function
  drawScore();

  // draw the player's cannon by invoking the corresponding function
  drawCannon(PLAYER_POSITION_X, height-PAD_HEIGHT, playerCannonDirection, PLAYER_COLOR);

  // draw the enemy's cannon by invoking the corresponding function
  drawCannon(enemyPositionX, height-PAD_HEIGHT, enemyCannonDirection, ENEMY_COLOR);
}

