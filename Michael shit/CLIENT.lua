--CLIENT--

local SLOT_COUNT = 16

local CLIENT_PORT = 0
local SERVER_PORT = 420

local modem = peripheral.wrap("left")
modem.open(CLIENT_PORT)

--I STOLE THIS FUNCTION
function split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function parseParams(data)
    coords = {}
    params = split(data, " ")
    
    coords[1] = vector.new(params[1], params[2], params[3])
    coords[2] = vector.new(params[4], params[5], params[6])
    coords[3] = vector.new(params[7], params[8], params[9])

    return (coords)
end

function getItemIndex(itemName)
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] == itemName) then
                return slot
            end
        end
    end
end

function checkFuel()
    if(turtle.getFuelLevel() < 100) then
        turtle.select(getItemIndex("enderstorage:ender_storage"))
        turtle.digUp()
        turtle.placeUp()
        --Chest is deployed
        
        turtle.suckUp()
    
        while(true) do
            bucketIndex = getItemIndex("minecraft:lava_bucket")
            if(bucketIndex == nil) then
                turtle.suckUp()
                turtle.dropUp()
            else
                turtle.select(bucketIndex)
                turtle.refuel()
                turtle.dropUp()
                turtle.digUp()
                return true
            end
        end
    end
    return true
end

--I STOLE THIS FUNCTION--
function getOrientation()
    loc1 = vector.new(gps.locate(2, false))
    if not turtle.forward() then
        for j=1,6 do
            if not turtle.forward() then
                turtle.dig()
            else 
                break 
            end
        end
    end
    loc2 = vector.new(gps.locate(2, false))
    heading = loc2 - loc1
    turtle.down()
    turtle.down()
    return ((heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3))
    end


function turnToFaceHeading(heading, destinationHeading)
    if(heading > destinationHeading) then
        for t = 1, math.abs(destinationHeading - heading), 1 do 
            turtle.turnLeft()
        end
    elseif(heading < destinationHeading) then
        for t = 1, math.abs(destinationHeading - heading), 1 do 
            turtle.turnRight()
        end
    end
end

function setHeadingZ(zDiff, heading)
    local destinationHeading = heading
    if(zDiff < 0) then
        destinationHeading = 2
    elseif(zDiff > 0) then
        destinationHeading = 4
    end
    turnToFaceHeading(heading, destinationHeading)

    return destinationHeading
end

function setHeadingX(xDiff, heading)
    local destinationHeading = heading
    if(xDiff < 0) then
        destinationHeading = 1
    elseif(xDiff > 0) then
        destinationHeading = 3
    end

    turnToFaceHeading(heading, destinationHeading)
    return destinationHeading
end

function digAndMove(n)
    for x = 1, n, 1 do
        while(turtle.detect()) do
            turtle.dig()
        end
        turtle.forward()
        checkFuel()
    end
end

function digAndMoveDown(n)
    for y = 1, n, 1 do
        while(turtle.detectDown()) do
            turtle.digDown()
        end
        turtle.down()
        checkFuel()
    end
end

function digAndMoveUp(n)
    for y = 1, n, 1 do
        while(turtle.detectUp()) do
            turtle.digUp()
        end
        turtle.up()
        checkFuel()
    end
end


function moveTo(coords, heading)
    local currX, currY, currZ = gps.locate()
    local xDiff, yDiff, zDiff = coords.x - currX, coords.y - currY, coords.z - currZ
    print(string.format("Distances from start: %d %d %d", xDiff, yDiff, zDiff))


    --    -x = 1
    --    -z = 2
    --    +x = 3
    --    +z = 4
    

    -- Move to X start
    heading = setHeadingX(xDiff, heading)
    digAndMove(math.abs(xDiff))

    -- Move to Z start
    heading = setHeadingZ(zDiff, heading)
    digAndMove(math.abs(zDiff))

    -- Move to Y start
    if(yDiff < 0) then    
        digAndMoveDown(math.abs(yDiff))
    elseif(yDiff > 0) then
        digAndMoveUp(math.abs(yDiff))
    end


    return heading
end


modem.transmit(SERVER_PORT, CLIENT_PORT, "CLIENT_DEPLOYED")
event, side, senderChannel, replyChannel, msg, distance = os.pullEvent("modem_message")
turtle.digUp()

-- Parse out coordinates and options
local args = split(msg, " ")
local withStorage = args[#args]
withStorage = withStorage == "1" and true or false
data = parseParams(msg)

checkFuel()

local startCoords = data[1]
local finalHeading = moveTo(startCoords, getOrientation())

local EAST_HEADING = 3
--Turn to face North
turnToFaceHeading(finalHeading, EAST_HEADING)
finalHeading = EAST_HEADING
--Now in Starting Position--

--------------------------------START MINING CODE-----------------------------------------





------------------------------------------------------------------------------------------

KEEP_ITEMS = {
    "minecraft:diamond",
    "minecraft:emerald",
    "minecraft:coal",
    "minecraft:iron_ore",
    "minecraft:gold_ore",
    "thermalfoundation:ore",
    "ic2:resource",
    "enderstorage:ender_storage",
    "computercraft:turtle_expanded"
}

function isDrop(item)
    for i = 1, #KEEP_ITEMS, 1 do
        if(item["name"] == KEEP_ITEMS[i]) then
            return false
        end
    end
    return true
end

function dropItems()
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(isDrop(item)) then
               turtle.select(slot)
               turtle.drop()
            end
        end
    end 
end

-- "computercraft:turtle_expanded"

function dropAllItems()
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] ~= "enderstorage:ender_storage" and item["name"] ~= "computercraft:turtle_expanded") then
                print("Dropping - " .. item["name"])
                turtle.select(slot)
                turtle.drop()
            end
        end
    end
end

function storeAllItems()
    turtle.select(getItemIndex("enderstorage:ender_storage"))
    turtle.digUp()      
    turtle.placeUp()  
    
    -- Chest is now deployed
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] ~= "minecraft:coal_block" and item["name"] ~= "minecraft:coal") then
                turtle.select(slot)
                turtle.dropUp()
            end
        end
    end
    -- Items are now stored

    turtle.digUp()
end




function manageInventory(withStorage)
    if(withStorage) then
        dropItems()
        storeAllItems()
    else
        dropAllItems()
    end

end

function detectAndDig()
    while(turtle.detect()) do
        turtle.dig()
    end
end

function forward()
    detectAndDig()
    turtle.forward()
end

function leftTurn()
    turtle.turnLeft()
    detectAndDig()
    turtle.forward()
    turtle.turnLeft()
end


function rightTurn()
    turtle.turnRight()
    detectAndDig()
    turtle.forward()
    turtle.turnRight()
end


function dropTier(heading)
    turtle.turnRight()
    turtle.turnRight()
    turtle.digDown()
    turtle.down()
    return flipDirection(heading)
end


function flipDirection(heading)
    return ((heading + 1) % 4) + 1
end

function turnAround(tier, heading)
    if(tier % 2 == 1) then
        if(heading == 2 or heading == 3) then
            rightTurn()
        elseif(heading == 1 or heading == 4) then
            leftTurn()
        end
    else
        if(heading == 2 or heading == 3) then
            leftTurn()
        elseif(heading == 1 or heading == 4) then
            rightTurn()
        end
    end
    
    return flipDirection(heading)
end



function startQuary(width, height, depth, heading)
    for tier = 1, height, 1 do
        for col = 1, width, 1 do
            for row = 1, depth - 1, 1 do
                if(not checkFuel()) then
                    print("Turtle is out of fuel, Powering Down...")
                    return
                end
                forward()
            end
            if(col ~= width) then
                heading = turnAround(tier, heading)
            end
            manageInventory(withStorage)
        end
        if(tier ~= height) then
            heading = dropTier(heading)
        end
    end
    return heading
end

local quary = data[2]
finishedHeading = startQuary(quary.x, quary.y, quary.z, finalHeading)



--------------------------------START RETURN TRIP CODE------------------------------------





------------------------------------------------------------------------------------------


function returnTo(coords, heading)
    local currX, currY, currZ = gps.locate()
    local xDiff, yDiff, zDiff = coords.x - currX, coords.y - currY, coords.z - currZ
    
    -- Move to Y start
    
    while(currY ~= coords.y) do
        if(yDiff < 0) then
            digAndMoveDown(math.abs(yDiff))
        elseif(yDiff > 0) then
            digAndMoveUp(math.abs(yDiff))
        end
        currX, currY, currZ = gps.locate()
        xDiff, yDiff, zDiff = coords.x - currX, coords.y - currY, coords.z - currZ
    end

    -- Move to X start
    heading = setHeadingX(xDiff, heading)
    digAndMove(math.abs(xDiff))

    -- Move to Z start
    heading = setHeadingZ(zDiff, heading)
    digAndMove(math.abs(zDiff))
    
    

    return heading
end

endCoords = data[3]
returnTo(endCoords, finishedHeading)
manageInventory(withStorage)


local timoutWait = 60
for i = 1, timoutWait, 1 do
    os.sleep(1)
    print(string.format( "Waiting for brothers %d/%d", i, timoutWait))
end

modem.transmit(SERVER_PORT, CLIENT_PORT, "cum")