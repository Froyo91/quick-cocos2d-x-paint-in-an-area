local MainScene = class("MainScene", function()
	return display.newScene("MainScene")
end)

local paint_area = nil
local paint_true_area = nil
local brush = nil
--绘制区域的长和宽
local dx = nil
local dy = nil

local layer = nil

function MainScene:ctor()
	--告诉我们我们可以绘制的区域
	paint_area = display.newSprite("b.png", display.cx, display.cy)
	self:addChild(paint_area)

	brush = CCSprite:create("a.png")
    	brush:setOpacity(100)
   	brush:retain()  --没有加到node里的sprite最好要retain一下，不过别忘了释放

   	dx = 220
   	dy = 220
   	paint_true_area = CCRenderTexture:create(dx, dy, kCCTexture2DPixelFormat_RGBA8888)
   	paint_true_area:retain()
    	paint_true_area:setPosition(display.cx, display.cy)
    	self:addChild(paint_true_area)

	layer = display.newLayer()
	self:addChild(layer)
	layer:setTouchEnabled(true)
	layer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		return self:onTouch(event.name, event.x, event.y)
	end)
end

local last_x = nil
local last_y = nil
--这一段代码是对luatest里的例子的简化
function MainScene:onTouch(name, x, y)
	if name == "began" then
		last_x = x
		last_y = y
	elseif name == "moved" then
		paint_true_area:begin()     
		local distance = cc.PointDistance(ccp(x, y), ccp(last_x, last_y))

		if distance > 0.1 then   --如果是distance > 1，那么可能出现画出来的线是有断点的，有一种断断续续的效果
			local d = distance
		   	local difx = last_x - x
		      	local dify = last_y - y  
			for i=0, d - 1 do
				local delta = i / distance                
				brush:setRotation(math.random(0, 359))
				--注意这里的偏移量
				brush:setPosition(ccp(x + (difx * delta) - (paint_true_area:getPositionX() - dx / 2), y + (dify * delta) - (paint_true_area:getPositionY() - dy / 2)))
				brush:visit()
			end
		end

		paint_true_area:endToLua()
	elseif name == "ended" then

	end
	last_x = x
	last_y = y
	return true
end

function MainScene:onEnter()
	local btnImage = "c.png"
	local btnSelectImage = "c.png"
	local btn = ui.newImageMenuItem({
		image = btnImage,
		imageSelected = btnSelectImage,
		listener = function()
			paint_true_area:clear(0, 0, 0, 0)
			return
		end,
	})
	btn:setPosition(display.left + 50, display.top - 50)
	self:markAutoCleanupImage(btnImage)
	self:markAutoCleanupImage(btnSelectImage)

	local menu = ui.newMenu({btn})
	self:addChild(menu)
end



function MainScene:onExit()
	--释放之前的sprite对象
	if brush ~= nil then
		brush:release()
	end
	if paint_true_area ~= nil then
		paint_true_area:release()
	end
end

return MainScene
