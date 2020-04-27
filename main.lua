local revupd=false --update top2bottom (glitchy) (default:false)
local gridResF=0.5 --grid resolution multiplier (1 will disable doUpsale) (default:0.5)
local resx,resy=600,400 --game resolution (0,0 for fullscreen) (default:600,400)
local doUpscale=true --upscale/downscale grid (NOT resolution) to fit window size (false can be faster) (default:true)
local enableVsync=true -- (default:true) - 60/30 fps lock
local enableTempSim=true -- (default:true) - experimental
local forceProtection=false -- (default:false) - experimental (glitchy)

rand = love.math.random
grid = require'grid'
require'elem'
local elem=elem

local function noopfn() end

local selected=1
local brushSize=3

function outlText(text,x,y,c1,c2) --говнокод, но работакт
  local g=love.graphics
  g.push()
  c1=c1 or {1,1,1,1}
  c2=c2 or {1-c1[1],1-c1[2],1-c1[3],c1[4]}
  c1[4]=c1[4] or 1
  c2[4]=c2[4] or 1
  g.setColor(unpack(c2))
  g.print(text,x+1,y+1)
  g.print(text,x-1,y-1)
  g.print(text,x+1,y-1)
  g.print(text,x-1,y+1)
  g.setColor(unpack(c1))
  g.print(text,x,y)
  g.pop()
end

function particle(elem,x,y,t)
  local p={}
  if t then
    p=t
  end
  p.elem=elem
  p.temp=0
  sim:set(x,y,p)
  return p
end

function love.load(arg)
  if gridResF==1 then doUpscale=false end
  pause=false
  love.window.setMode(resx,resy,{vsync=enableVsync})
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
  local grid=grid
  local protected={}
  
  local fa,fb,fc=sim.h,1,-1
  if revupd then
    fa,fb,fc=1,sim.h,1
  end
  for i=1,sim.w do
    for j=fa,fb,fc do
      local obj = sim:get(i,j)
      if not(obj == grid.nul) then 
        
        local col=obj.color or obj.elem.color
        local heatV=(obj.temp/100)/2
        g.setColor((col[1] or 1)+heatV,(col[2] or 1)-heatV,(col[3] or 1)-heatV,col[4] or 1)
        
        local shader=obj.shader or obj.elem.shader
        if shader then
          love.graphics.setShader(shader)
        end
        
        if doUpscale then
          love.graphics.rectangle('fill',i*rw,j*rh,rw,rh)
        else
          love.graphics.points(i+0.1,j) 
        end
        
        if shader then
          love.graphics.setShader()
        end
        
        if not pause then
          
          if enableTempSim then
            local n=sim:neighbors(i,j)
            local totalHeat=0
            local heatSrc=0
            for i,v in ipairs(n) do
              if not(v==grid.nul) then
                heatSrc=heatSrc+1
                totalHeat=totalHeat+v.temp
              end
            end
            if heatSrc>0 then
              local avg=totalHeat/heatSrc
              if obj.temp>avg-1 then
                for i,v in ipairs(n) do
                  if not(v==grid.nul) then
                    v.temp=avg
                  end
                end
              else
                obj.temp=avg
              end
            end
          end
        
          local toRun = obj.update or obj.elem.update
          if toRun and not(protected[obj]) then
            if obj.protect or obj.elem.protect or forceProtection then
              protected[obj]=true
            end 
            toRun(sim,i,j)
          end
        end
      end 
    end
  end
  g.setColor(1,1,1,1)
  g.print(string.format(
    '%s FPS, grid size: %sX%s RAM:%s kb \n %s (use 1-%s keys)',
    love.timer.getFPS(),sim.w,sim.h,math.floor(collectgarbage('count')),selector[selected],#selector)
  )
  if not(doUpscale) then
    g.setColor(1,0,0)
    g.rectangle('line',1,1,sim.w*rw,sim.h*rh)
  end
  g.setColor(1,1,1)
  g.rectangle('line',mx-brushSize/rw2,my-brushSize/rh2,brushSize/rw2*2+2,brushSize/rh2*2+2)
  
  if not(hover==grid.nul) then
    local info=(hover.name or hover.elem.name or '???')..'\nx='..wmx..' y='..wmy..'\n'
    for i,v in pairs(hover) do
      if not(type(v)=='table') then
        info=info..i..'='..v..'\n'
      end
    end
    local c=hover.color or hover.elem.color or {1,1,1}
    outlText(info,mx+brushSize+12,my-brushSize,c,{0,0,0})
  end
end

function love.update(dt)
  if selected<1 then selected=1 end
  if selected>#selector then selected=#selector end
    
  local lm=love.mouse
  m1,m2=lm.isDown(1),lm.isDown(2)
  mx,my=lm.getX(),lm.getY()
  if love.keyboard.isDown('s') then
    mx=math.floor(mx/brushSize)*brushSize+brushSize/2
    my=math.floor(my/brushSize)*brushSize+brushSize/2
  end
  wmx,wmy=math.floor(mx/rw),math.floor(my/rw)
  
  
  --if m1 or m2 then
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
        if love.keyboard.isDown('h') then
          local obj=sim:get(psx,psy)
          if not(obj==grid.nul) then
            obj.temp=obj.temp+0.15
          end
        end
      end
    end
  --end
  
  hover=sim:get(wmx,wmy)
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