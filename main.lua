--[[

glemasters
poetics of mobile, etc., etc.

I'm going to start with the last bit of code I posted -- where we built a simple building with windows, its upper left-hand corner at 0,0 -- and edit it in order to allow us to move things about, repeat them, etc.  To that end, I'm deleting all of the previous comments.  The comments you see below are related to the new features.

There are at least three ways of going about this without changing our code too significantly.  We could:

1.  Stuff everything into a few display.newGroup()s
2.  Stuff everything into a few tables;
3.  Add an x,y argument to the installWindows function.

All 3 are pretty simple.  Let's start with number 3, but 
add-in number 1 as well.  Groups are easy.

What all of this means to us as programmers who USE this function:

0. I no longer display my own building frame -- the function does this for me (based on variables I was already providing);
1. I now need to adjust my code to pass 2 new integers (x and y) in addition to the others;
2. I now need to expect to get something back:  A group (i.e., a display object).

]]--

-- For the sake of consistency, I'm adding the x and y to the very
-- beginning of the function call.  Additionally (and this is
-- very important, and perhaps a bit different) I'm going to make 
-- x refer to the left side of the building, and y will
-- refer to the ground floor of the building, its base.
-- Frankly, that's a bit odd, and I'm not sure if others
-- would do it that way, but in the future, chances are 
-- I'll always know where the building sits -- not where
-- it needs to reach to in the sky.  It also means that
-- x and y aren't the "same" (both at 0, both in the center,
-- etc)... so we'll need to warn other users of that fact
-- prominently.  In the end, though, it just means that we'll 
-- need to do a bit more math.

local function installWindows( bX, bY, bW, bRC, bH, bFC )

	local bldgX = bX -- LEFT HAND HORIZONTAL POSITION
	local bldgY = bY -- THE FLOOR, THE BASE

	local bldgLayers = display.newGroup() -- groups are just like
	-- photoshop layers.  Start from the bottom and work up.  The
	-- last layer you place -- the top-most layer -- may obscure
	-- anything on the previous layers.  But since they
	-- act as a single unit, I can essentially pretend that the group
	-- is a jpg or png.

	-- most of this works as-is

	local bldgWidth = bW
	local bldgHeight = bH
	local bldgFloorCount = bFC
	local bldgRoomCount = bRC

	local windowWidthToRoomWidthRatio = 1 / 2
	local windowHeightToFloorHeightRatio = 1 / 2 

	local bldgRoomWidth = math.round( bldgWidth / bldgRoomCount )
	local bldgFloorHeight = math.round( bldgHeight / bldgFloorCount )
	local bldgWindowWidth = math.round( bldgRoomWidth * windowWidthToRoomWidthRatio )
	local bldgWindowHeight = math.round( bldgFloorHeight * windowHeightToFloorHeightRatio )

	local roomCenterX = bldgRoomWidth * 0.50
	local roomCenterY = bldgFloorHeight * 0.50

	local remainderX = bldgWidth - ( bldgRoomWidth * bldgRoomCount )
	local remainderY = bldgHeight - ( bldgFloorHeight * bldgFloorCount )
	remainderX = remainderX * 0.5
	remainderY = remainderY * 0.5

	local windowCenterX = bldgWindowWidth * 0.5
	local windowCenterY = bldgWindowHeight * 0.5 
	local windowAnchorX = remainderX - roomCenterX
	local windowAnchorY = remainderY - roomCenterY

	local windowLightsOn = { 1, .8, .2 }

	local buildingColor = { .3, .3, .3 } -- NEW (kinda)

	-- Our x position is the far left; Corona expects it to be in the middle.
	-- So if I passed installWindows ( 300, 500, 50, 5, 100, 10), based on the
	-- way I've designed things, I'm expecting the building's left edge to be
	-- at 300, its base at 500, its width as 50 and its height as 100.
	-- Meaning a rectangle from (upper left) 300,400 to 350,500 (lower right).
	-- BUT if I ask corona to draw a rectangle (300,500,50,100), I'll
	-- get upper left: (275, 450) to lower right: (325, 550).
	-- So we need to do some juggling.

	local bldgAdjustX = bldgX + ( bldgWidth * 0.5 ) -- corona's middle of building
	-- let's use our windowAnchorX to get the job done.  Recall that
	-- it was working in order to give us the necessary R and L margins inside
	-- the building.  We just need to tweak by adding the new xposition to it.

	local windowAdjustX = bldgX + windowAnchorX

	local bldgAdjustY = bldgY - ( bldgHeight * 0.5 )

	local windowAdjustY = bldgY + windowAnchorY - bldgHeight

	-- In sum:  bdlgAdjust x and y point to the middle, in spite of the fact
	-- that our users gave us the lower left-hand coordinate (because
	-- it was easier for them to do so).  windowAdjustX is the starting
     -- point for a left-most window; windowAdjustY is the starting point
     -- for a top-most window (thus, we've subtracted bldgHeight, because
     -- (sigh) on the y-axis, lower numbers (e.g., 0) are at the top, 
     -- not the bottom.
     -- Draw the building shell as promised:

	local bldgShell = display.newRect( bldgAdjustX, bldgAdjustY, bldgWidth, bldgHeight )
	bldgShell.fill = buildingColor



     -- Voilà.  Now I adjust the For-loop a tiny bit...  I substitute
     -- windowAdjustX and windowAdjustY for the old-fashioned, out-of-date
     -- windowAnchorX, windowAnchorY.  AND (big deal, kinda) I
     -- stuff everything into my Group(), starting with the building itself.

     bldgLayers:insert(bldgShell) -- always do lowest layer first.

	for column = 1, bldgRoomCount do
		for row = 1, bldgFloorCount do
			local xPos = windowAdjustX + (column * bldgRoomWidth) -- here
			local yPos = windowAdjustY + (row * bldgFloorHeight) -- here
			local window = display.newRect (xPos, yPos, bldgWindowWidth, bldgWindowHeight)
			window.fill = windowLightsOn
			bldgLayers:insert(window)
		end
	end

	-- Finally:  we've got our layered building, but we need to control
	-- it.  That's why we rewrote the initial call to expect a RETURN.
	-- specifically:  a returned GROUP.

	return bldgLayers

end

local groundLevel = display.contentHeight * 0.95 -- ground level!
local buildingOne = installWindows( 50, groundLevel, 300, 5, 600, 14 )

-- Let's see if I can move things about.

transition.to(buildingOne, {time = 7500, x = display.contentWidth / 1.25} )

-- Oh, I can.  for example:

-- buildingOne.x = 400
-- buildingOne.isVisible = false
-- etc.

-- Still I'm left with no way to exercise individual control
-- over the windows, say.  That's why we'll need tables...