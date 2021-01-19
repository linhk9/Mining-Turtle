KEEP_ITEMS = {
  "minecraft:diamond",
  "minecraft:emerald",
  "minecraft:coal",
  "minecraft:iron_ore",
  "minecraft:gold_ore",
  "computercraft:turtle_expanded"
}

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
    turtle.select(16)
    turtle.placeUp()
  end
  
  local run = 0
  term.write("Comprimento do túnel: ")
  run = read()
  
  for i = 1, run do
    k = i - 1
    j = k % 4
    digIt()
    turtle.turnLeft()
    digIt()
    turtle.turnRight()
    turtle.turnRight()
    turtle.forward()
    digIt()
    turtle.back()
    turtle.turnLeft()
    if i == 2 or j == 1 then
      turtle.back()
      turtle.turnRight()
      turtle.forward()
      placeTorch()
      turtle.back()
      turtle.turnLeft()
      turtle.forward()
    end
    if i == 5 or J == 5 then
      turtle.back()
      turtle.turnLeft()
      turtle.forward()
      placeTorch()
      turtle.back()
      turtle.turnRight()
      turtle.forward()
    end
  end