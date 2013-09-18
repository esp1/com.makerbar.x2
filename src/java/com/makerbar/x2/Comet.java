import processing.core.*;

public class Comet
{
  static final int diameter = 5;
  static final int speed = 5;

  public static final int DIRECTION_UP = 0;
  public static final int DIRECTION_UPRIGHT = 1;
  public static final int DIRECTION_RIGHT = 2;
  public static final int DIRECTION_DOWNRIGHT = 3;
  public static final int DIRECTION_DOWN = 4;
  public static final int DIRECTION_DOWNLEFT = 5;
  public static final int DIRECTION_LEFT = 6;
  public static final int DIRECTION_UPLEFT = 7;

  static int sphereWidth;
  static int sphereHeight;

  public int startingX;
  public int startingY;
  int yMovementDirection;
  int xMovementDirection;
  public int cometColor;

  public int positionX;
  public int positionY;

  public Comet (int x, int y, int direction, int c)
  {
    positionX = startingX = x;
    positionY = startingY = y;
    cometColor = c;

    if (direction == DIRECTION_DOWNLEFT || direction == DIRECTION_DOWN || direction == DIRECTION_DOWNRIGHT)
    {
      yMovementDirection = 1;
    }
    else if (direction == DIRECTION_UPLEFT || direction == DIRECTION_UP || direction == DIRECTION_UPRIGHT)
    {
      yMovementDirection = -1;
    }

    if (direction == DIRECTION_UPRIGHT || direction == DIRECTION_RIGHT || direction == DIRECTION_DOWNRIGHT)
    {
      xMovementDirection = 1;
    }
    else if (direction == DIRECTION_UPLEFT || direction == DIRECTION_LEFT || direction == DIRECTION_DOWNLEFT)
    {
      xMovementDirection = -1;
    }
  }

  static void setSphereParameters(int theWidth, int theHeight)
  {
    sphereWidth = theWidth;
    sphereHeight = theHeight;
  }

  void update()
  { 
    positionX += speed * xMovementDirection;
    if (positionX > sphereWidth) positionX = 0;
    else if (positionX < 0) positionX = sphereWidth;

    positionY += speed * yMovementDirection;
    if (positionY > sphereHeight)
    {
      positionY = sphereHeight;
      positionX += (sphereWidth / 2);
      if (positionX > sphereWidth) positionX %= sphereWidth;
      yMovementDirection *= -1;
    }
    else if (positionY < 0)
    {
      positionY = 0;
      positionX += (sphereWidth / 2);
      if (positionX > sphereWidth) positionX %= sphereWidth;
      yMovementDirection *= -1;
    }

    /*
    if (xMovementDirection)
     {
     positionX += speed;
     
     if (positionX >= sphereWidth)
     {
     positionX = 0;
     }
     }
     else
     {
     positionX += speed;
     
     if (positionX <= 0)
     {
     positionX = sphereWidth;
     }
     }
     */

    /*
    if (yMovementDirection)
     {
     positionY += speed;
     
     if (positionY >= sphereHeight)
     {
     positionY = sphereHeight;
     positionX += (sphereWidth / 2);
     if (positionX > sphereWidth) positionX %= sphereWidth;
     yMovementDirection = false;
     }
     }
     else
     {
     positionY -= speed;
     
     if (positionY <= 0)
     {
     positionY = 0;
     positionX += (sphereWidth / 2);
     if (positionX > sphereWidth) positionX %= sphereWidth;
     yMovementDirection = true;
     }
     }
     */
  }

  public int getDirection()
  {
    if (xMovementDirection == -1)
    {
      if (yMovementDirection == -1)
      {
        return DIRECTION_UPLEFT;
      }
      else if (yMovementDirection == 0)
      {
        return DIRECTION_LEFT;
      }
      else if (yMovementDirection == 1)
      {
        return DIRECTION_DOWNLEFT;
      }
    }
    else if (xMovementDirection == 0)
    {
      if (yMovementDirection == -1)
      {
        return DIRECTION_UP;
      }
      else if (yMovementDirection == 1)
      {
        return DIRECTION_DOWN;
      }
    }
    else if (xMovementDirection == 1)
    {
      if (yMovementDirection == -1)
      {
        return DIRECTION_UPRIGHT;
      }
      else if (yMovementDirection == 0)
      {
        return DIRECTION_RIGHT;
      }
      else if (yMovementDirection == 1)
      {
        return DIRECTION_DOWNRIGHT;
      }
    }
    return -1;
  }
}

