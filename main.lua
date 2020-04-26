
local timestep=1 --increases speed on powerful cpu's (default:1)
local revupd=false --update top2bottom (enable update_protect) (default:false)
local update_protect=false --prevents object from updating twice (glitchy) (default:false)
local gridResF=0.5 --grid resolution multiplier (1 will disable doUpsale) (default:0.5)
local resx,resy=600,400 --game resolution (0,0 for fullscreen) (default:600,400)
local doUpscale=true --upscale/downscale grid (NOT resolution) to fit window size (false can be faster) (default:true)

rand = love.math.random
grid = require'grid'
require'elem'
local elem=elem

local function noopfn() end

local selected=1
local brushSize=3

function particle(elem,x,y,t)
  local p={}
  if t then
    p=t
  end
  p.elem=elem
  p.uid=rand(9999999999999)
  sim:set(x,y,p)
  return p
end

function love.load(arg)
  if gridResF==1 then doUpscale=false end
  pause=false
  love.window.setMode(resx,resy,{vsync=1})
  w,h = love.graphics.getWidth(),love.graphics.getHeight()
  sim = grid.new(w/(1/gridResF),h/(1/gridResF))
  rw,rh=1,1
  rw2,rh2=w/sim.w,h/sim.h
  if doUpscale then
    rw,rh=rw2,rh2
    rw2,rh2=1,1
  end
end

function love.draw() 
  local g = love.graphics
  local sim=sim
  for i=1,sim.w do
    for j=1,sim.h do
      local obj = sim:get(i,j)
      if obj ~= grid.nul then
        local col=obj.color or obj.elem.color
        g.setColor(col[1] or 1,col[2] or 1,col[3] or 1,col[4] or 1)
        if doUpscale then
          g.rectangle('fill',i*rw,j*rh,rw,rh)
        else
          g.points(i+0.1,j) 
        end
      end
    end
  end
  g.setColor(1,1,1,1)
  g.print(string.format(
    ' %s FPS grid size: %sX%s RAM:%s kb \n %s (use 1-%s keys)',
    love.timer.getFPS(),sim.w,sim.h,math.floor(collectgarbage('count')),selector[selected],#selector)
  )
  if not(doUpscale) then
    g.setColor(1,0,0)
    g.rectangle('line',1,1,sim.w*rw,sim.h*rh)
  end
  g.setColor(1,1,1)
  g.rectangle('line',0+mx-brushSize/rw2,3+my-brushSize/rh2,brushSize/rw2*2,brushSize/rh2*2)
end

function love.update(dt)
  if selected<1 then selected=1 end
  if selected>#selector then selected=#selector end
    
  local lm=love.mouse
  m1,m2=lm.isDown(1),lm.isDown(2)
  mx,my=lm.getX(),lm.getY()
  wmx,wmy=math.floor(mx/rw),math.floor(my/rw)
  
  if m1 or m2 then
    for i=0,brushSize do
      for j=0,brushSize do
        local psx,psy=wmx+i-math.floor(brushSize/2),wmy+j-math.floor(brushSize/2)
        if m1 then
          if sim:get(psx,psy)==grid.nul then
            particle(elem[selector[selected]],psx,psy)
          end
        elseif m2 then
          sim:set(psx,psy,grid.nul)
        end
      end
    end
  end
  
  local updated={}
  if not pause then
    for _=1,timestep do
      for i=1,sim.w do
        local fa,fb,fc=sim.h,1,-1
        if revupd then
          fa,fb,fc=1,sim.h,1
        end
        for j=fa,fb,fc do
          local obj = sim:get(i,j)
          if obj ~= grid.nul then
            if not(update_protect) or not(updated[obj.uid]) then
              if update_protect then
                updated[obj.uid]=true
              end
              (obj.update or obj.elem.update or noopfn)(sim,i,j)
            end
          end
        end
      end
    end
  end
end

function love.wheelmoved(x,y)
  brushSize=math.min(math.max(brushSize+y,1),sim.h/2)
end

function love.keypressed(k)
  local ton = tonumber(k)
  if k=='space' then 
    pause=not(pause) 
  end
  if ton then
    selected=ton
  end
end

--[[
elseif mode==2 then
      for _=1,timestep do
        if not (updj and updi) then updi,updj=1,sim.h end
        updj=updj-1
        if updj<1 then
          updj=sim.h
          updi=updi+1
        end
        if updi>sim.w then
          updi,updj=1,sim.h
        end
        updloop(updi,updj)
      end
    end
  end
  
  if y~=0 then
    selected=selected+math.floor(math.max(-1,math.min(1,y)))
    if selected<1 then selected=#selector end
  if selected>#selector then selected=1 end
  end
]]