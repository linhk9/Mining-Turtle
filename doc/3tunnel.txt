function digIt()
    while turtle.detect() do
      turtle.dig()
      os.sleep(0.5)
    end
    turtle.forward()
    while turtle.detectDown() or turtle.detectUp() do
      turtle.digUp()
      turtle.digDown()
    end
  end
  
  local run = 0
  term.write("Tunnel length: ")
  run = read()
  
  for i = 1, run do
    digIt()
    turtle.turnLeft()
    digIt()
    turtle.turnRight()
    turtle.turnRight()
    turtle.forward()
    digIt()
    turtle.back()
    turtle.turnLeft()
  end