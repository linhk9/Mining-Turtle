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
  
  function placeTorch()
    turtle.down()
    turtle.back()
    turtle.select(16)
    turtle.placeUp()
    turtle.forward()
    turtle.up()
  end
  
  local run = 0
  local j = 0
  local k = 0
  
  term.write("Branch length: ")
  run = read()
  
  for i = 1, run do
    k = i - 1
    j = k % 10
    if j == 1 then
      placeTorch()
    end
    digIt()
  end
  
  turtle.down()
  turtle.turnRight()
  turtle.turnRight()
  turtle.select(16)
  turtle.placeUp()
  
  for i = 1, run do
    turtle.forward()
  end