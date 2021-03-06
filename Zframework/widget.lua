local gc=love.graphics
local kb=love.keyboard
local int=math.floor
local format=string.format
local next=next
local EMPTY={}

local button={
	type="button",
	ATV=0,--activating time(0~8)
}
function button:reset()
	self.ATV=0
end
function button:isAbove(x,y)
	return x>self.x-self.ATV and x<self.x+self.w+2*self.ATV and y>self.y-self.ATV and y<self.y+self.h+2*self.ATV
end
function button:FX()
	sysFX.new("ripple",.16,self.x-self.ATV,self.y-self.ATV,self.w+2*self.ATV,self.h+2*self.ATV)
end
function button:update()
	if WIDGET.sel==self then
		if self.ATV<8 then self.ATV=self.ATV+1 end
	else
		if self.ATV>0 then self.ATV=self.ATV-1 end
	end
end
function button:draw()
	local x,y,w,h=self.x,self.y,self.w,self.h
	local r,g,b=unpack(self.color)
	gc.setColor(.2+r*.8,.2+g*.8,.2+b*.8,.7)
	gc.rectangle("fill",x-self.ATV,y-self.ATV,w+2*self.ATV,h+2*self.ATV)
	if self.ATV>0 then
		gc.setLineWidth(4)
		gc.setColor(1,1,1,self.ATV*.125)
		gc.rectangle("line",x-self.ATV+2,y-self.ATV+2,w+2*self.ATV-4,h+2*self.ATV-4)
	end
	local t=self.text
	if t then
		if type(t)=="function"then t=t()end
		setFont(self.font)
		local y0=y+h*.5-self.font*.7
		gc.setColor(1,1,1,.3)
		gc.printf(t,x-2,y0-2,w,"center")
		gc.printf(t,x-2,y0+2,w,"center")
		gc.printf(t,x+2,y0-2,w,"center")
		gc.printf(t,x+2,y0+2,w,"center")
		gc.setColor(r*.5,g*.5,b*.5)
		gc.printf(t,x,y0,w,"center")
	end
end
function button:getInfo()
	print(format("x=%d,y=%d,w=%d,h=%d,font=%d",self.x+self.w*.5,self.y+self.h*.5,self.w,self.h,self.font))
end

local switch={
	type="switch",
	ATV=0,--activating time(0~8)
	CHK=0,--check alpha(0~6)
}
function switch:reset()
	self.ATV=0
	self.CHK=0
end
function switch:isAbove(x,y)
	return x>self.x and x<self.x+50 and y>self.y-25 and y<self.y+25
end
function switch:update()
	local _=self.ATV
	if WIDGET.sel==self then if _<8 then self.ATV=_+1 end
	else if _>0 then self.ATV=_-1 end
	end
	_=self.CHK
	if self:disp()then if _<6 then self.CHK=_+1 end
	else if _>0 then self.CHK=_-1 end
	end
end
function switch:draw()
	local x,y=self.x,self.y-25
	if self.ATV>0 then
		gc.setColor(1,1,1,self.ATV*.08)
		gc.rectangle("fill",x,y,50,50)
	end
	if self.CHK>0 then
		gc.setColor(.9,1,.9,self.CHK/6)
		gc.setLineWidth(6)
		gc.line(x+5,y+25,x+18,y+38,x+45,y+11)
	end
	--checked
	gc.setLineWidth(4)
	gc.setColor(1,1,1,.6+self.ATV*.05)
	gc.rectangle("line",x,y,50,50)
	--frame
	local t=self.text
	if t then
		gc.setColor(1,1,1)
		setFont(self.font)
		gc.printf(t,x-412,y+20-self.font*.7,400,"right")
	end
end
function switch:getInfo()
	print(format("x=%d,y=%d,font=%d",self.x,self.y,self.font))
end

local slider={
	type="slider",
	ATV=0,--activating time(0~8)
	pos=0,--position shown
}
function slider:reset()
	self.ATV=0
	self.pos=0
end
function slider:isAbove(x,y)
	return x>self.x-10 and x<self.x+self.w+10 and y>self.y-20 and y<self.y+20
end
function slider:update()
	if WIDGET.sel==self then
		if self.ATV<6 then self.ATV=self.ATV+1 end
	else
		if self.ATV>0 then self.ATV=self.ATV-1 end
	end
	if not(self.hide and self.hide())then
		self.pos=self.pos*.7+self.disp()*.3
	end
end
function slider:draw()
	local x,y=self.x,self.y
	gc.setColor(1,1,1,.5+self.ATV*.06)
	gc.setLineWidth(2)
	local x1,x2=x,x+self.w
	for p=0,self.unit do
		local x=x1+(x2-x1)*p/self.unit
		gc.line(x,y+7,x,y-7)
	end
	--units
	gc.setLineWidth(4)
	gc.line(x1,y,x2,y)
	--axis
	local t=self.text
	if t then
		gc.setColor(1,1,1)
		setFont(self.font)
		gc.printf(t,x-312,y-self.font*.7,300,"right")
	end
	--text
	local x,y,w,h=x1+(x2-x1)*self.pos/self.unit-10-self.ATV*.5,y-16-self.ATV,20+self.ATV,32+2*self.ATV
	gc.setColor(.8,.8,.8)
	gc.rectangle("fill",x,y,w,h)
	if self.ATV>0 then
		gc.setLineWidth(2)
		gc.setColor(1,1,1,self.ATV*.16)
		gc.rectangle("line",x+1,y+1,w-2,h-2)
	end
	--block
end
function slider:getInfo()
	print(format("x=%d,y=%d,w=%d",self.x,self.y,self.w))
end

local WIDGET={}
WIDGET.active=EMPTY--table, contains all active widgets
WIDGET.sel=nil--selected widget
function WIDGET.set(L)
	WIDGET.sel=nil
	WIDGET.active=L or EMPTY
	if L then
		for _,W in next,L do
			W:reset()
		end--Reset all widgets
	end
end

WIDGET.new={}
function WIDGET.new.button(x,y,w,h,color,font,code,hide,N)
	local _={
		x=x-w*.5,y=y-h*.5,
		w=w,h=h,
		color=color,
		font=font,
		code=code,
		hide=hide,
		next=N,
	}for k,v in next,button do _[k]=v end return _
end
function WIDGET.new.switch(x,y,font,disp,code,hide,N)
	local _={
		x=x,y=y,font=font,
		disp=disp,
		code=code,
		hide=hide,
		next=N,
	}for k,v in next,switch do _[k]=v end return _
end
function WIDGET.new.slider(x,y,w,unit,font,change,disp,code,hide,N)
	local _={
		x=x,y=y,
		w=w,unit=unit,
		font=font,
		change=change,
		disp=disp,
		code=code,
		hide=hide,
		next=N,
	}for k,v in next,slider do _[k]=v end return _
end

function WIDGET.moveCursor(x,y)
	WIDGET.sel=nil
	for _,W in next,WIDGET.active do
		if not(W.hide and W.hide())and W:isAbove(x,y)then
			WIDGET.sel=W
			return
		end
	end
end
function WIDGET.press(x,y)
	local W=WIDGET.sel
	if not W then return end
	if W.type=="button"then
		W.code()
		W:FX()
		SFX.play("button")
		VOC.play("nya")
	elseif W.type=="switch"then
		W.code()
		SFX.play("move",.6)
	elseif W.type=="slider"then
		if not x then return end
		local p,P=W.disp(),x<W.x and 0 or x>W.x+W.w and W.unit or int((x-W.x)*W.unit/W.w+.5)
		if p==P then return end
		W.code(P)
		if W.change then W.change()end
	end
	if W.hide and W.hide()then WIDGET.sel=nil end
end
function WIDGET.drag(x,y,dx,dy)
	local W=WIDGET.sel
	if not W then return end
	if W.type=="slider"then
		local p,P=W.disp(),x<W.x and 0 or x>W.x+W.w and W.unit or int((x-W.x)*W.unit/W.w+.5)
		if p==P then return end
		W.code(P)
		if W.change then W.change()end
	elseif not W:isAbove(x,y)then
		WIDGET.sel=nil
	end
end
function WIDGET.keyPressed(i)
	if i=="tab"then
		if WIDGET.sel then
			WIDGET.sel=kb.isDown("lshift")and WIDGET.sel.prev or WIDGET.sel.next or WIDGET.sel
		else
			WIDGET.sel=select(2,next(WIDGET.active))
		end
	elseif i=="space"or i=="return"then
		if WIDGET.sel then
			WIDGET.press(WIDGET.sel)
		end
	elseif i=="left"or i=="right"then
		local W=WIDGET.sel
		if W then
			if W.type=="slider"then
				local p=W.disp()
				local P=i=="left"and(p>0 and p-1)or p<W.unit and p+1
				if p==P or not P then return end
				W.code(P)
				if W.change then W.change()end
			end
		end
	end
end
function WIDGET.gamepadPressed(i)
	if i=="dpup"or i=="dpdown"then
		if WIDGET.sel then
			WIDGET.sel=i=="dpup"and WIDGET.sel.prev or WIDGET.sel.next or WIDGET.sel
		else
			WIDGET.sel=select(2,next(WIDGET.active))
		end
	elseif i=="start"then
		if WIDGET.sel then
			WIDGET.press(WIDGET.sel)
		end
	elseif i=="dpleft"or i=="dpright"then
		if WIDGET.sel then
			local W=WIDGET.sel
			if W.type=="slider"then
				local p=W.disp()
				local P=i=="left"and(p>0 and p-1)or p<W.unit and p+1
				if p==P or not P then return end
				W.code(P)
				if W.change then W.change()end
			end
		end
	end
end

function WIDGET.update()
	for _,W in next,WIDGET.active do W:update()end
end
function WIDGET.draw()
	for _,W in next,WIDGET.active do
		if not(W.hide and W.hide())then
			W:draw()
		end
	end
end

return WIDGET