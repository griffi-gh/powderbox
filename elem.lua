local gravity=4

local sandChk=3

local waterChk=6
local waterStyle=true --random water color



selector={'wall','sand','water','virus','caus','clne','fire','colorwall'}


local liqDraw=function(i,j,obj,sim,rw,rh)
        love.graphics.circle('fill',i,j,(rw+rh)/2+1)
      end

elem = {
    sand={
      name='sand',
      gtype='POW',
      update = function(t,x,y) --sand 3.0
        local nx,ny,i=t:flow(x,y,0,1,gravity)
        if not(i) then
          x,y,i=t:flow(x,y,-1,1,sandChk)
          if not(i) then
            x,y=t:flow(x,y,1,1,sandChk)
          end
        end
      end,
      color={1,1,0.2}
    },
    wall={
      name='wall',
      gtype='STA',
      color={0.5,0.5,0.5}
    },
    water={ 
      name='water',
      gtype='LIQ',
      color={0.1,0.1,1,0.5},
      update = function(t,x,y)--water 2.0
        local nx,ny,i=t:flow(x,y,0,1,gravity)
        if not(i) then
          if rand(2)==1 then
            x,y=t:flow(x,y,-1,0,waterChk)
          else
            x,y=t:flow(x,y,1,0,waterChk)
          end
        end
      end,
      draw=liqDraw,
      setup=function(t,x,y,o)
        if waterStyle then
          o.color={unpack(o.elem.color)}
          local toadd = (rand()/10)
          o.color={o.color[1]-toadd,o.color[2]-toadd,o.color[3]+toadd,o.color[4]}
        end
      end
    },
    caus={
      name='caus',
      gtype='GAS',
      color={1,0.5,1},
      update = function(t,x,y) 
        if rand(255)==1 then
          t:set(x,y,grid.nul)
        end
        t:move(x,y,x+(rand(0,2)-1),y+(rand(0,2)-1))
      end
    },
    virus={
      name='virus',
      gtype='STA',
      color={1,0.5,1},
      update = function(t,x,y) 
        for i=-1,1 do
          for j=-1,1 do
            if not(j==0 and i==0) then
              local tobj=t:get(x+i,y+j)
              if tobj and tobj.elem~=elem.virus then
                if rand(30)==1 then
                  local d={ctype=tobj.elem,cname=tobj.elem.name}
                  particle(elem.virus,x+i,y+j,d)
                end
              end
            end
          end
        end
      end
    },
    colorwall={
      name='colorwall',
      color={1,1,1,1},
      update = function(t,x,y) 
        local me=t:get(x,y)
        local neigh=t:neighbors(x,y)
        local r,g,b=0,0,0
        local c=0
        for i,v in ipairs(neigh) do
          if v~=grid.nul then
            local colh=v.color or v.elem.color
            if colh then
              c=c+1
              r=r+colh[1]
              g=g+colh[2]
              b=b+colh[3]
            end
          end
        end
        local cc=1/c
        local lim=0.9
        if c>0 then
          me.color={
            math.min(r*cc,lim),
            math.min(g*cc,lim),
            math.min(b*cc,lim)
          }
        end
      end
    },
    clne={
      name='clne',
      color={1,0,1,1},
      setup=function(t,x,y,o)
        o.ctype=nil
        o.delay=15
        o.secret.time=0
      end,
      update=function(t,x,y,o)
        if o.ctype then
          local c=o.ctype.color
          o.color={c[1]/2,c[2]/2,c[3]/2}
        end
        for i,v in ipairs(t:neighbors(x,y,0))do
          if v==0 then
            if o.ctype then
              if (o.secret.time or 0)>(o.delay or 1) then
                local npx,npy=t:getNeighborXY(x,y,i)
                particle(o.ctype,npx,npy)
                o.secret.time=0
              end
            end
          else
            if not(v.elem==elem.clne) then
              if not(o.ctype) --[[or o.ctype~=v.elem]] then
                o.ctype=v.elem
                o.cname=o.ctype.name
                break
              end
            elseif o.ctype then
              v.ctype=o.ctype
              v.cname=o.ctype.name
            end
          end
        end
        o.secret.time=(o.secret.time or 0)+1
      end
    },
    fire={
      protect=true,
      name='fire',
      color={0.88,0.34,0.13},
      setup=function(t,x,y,o)
        o.secret.maxlife=14
        o.life=rand(o.secret.maxlife/2,o.secret.maxlife)
      end,
      update=function(t,x,y,o)
        o.color=o.color or o.elem.color
        o.color[1]=o.elem.color[1]/(o.life/o.secret.maxlife)
        o.life=o.life-1
        if o.life>0 then
          t:flow(x,y,0,-1,gravity)
        else
          t:set(x,y,grid.nul)
        end
      end,
      draw=function(i,j,obj,sim,rw,rh)
        love.graphics.rectangle('fill',i,j-rh,rw,rh*3)
      end
    }
  }
  
  
  
  --[[
  
        if neigh[2] then
          if neigh[1]==grid.nul then
            t:move(x,y,x-1,y-1)
            return
          elseif neigh[3]==grid.nul then
            t:move(x,y,x+1,y-1)
            return
          end
        elseif neigh[2]==grid.nul then
          local neigh2=t:neighbors(x,y-1)
          local drs=-1
          if fastSand and neigh2[2]==grid.nul then
            drs=-2
          end
          t:move(x,y,x,y+drs)
          return
        end
        ]]
        
        --[[
        water={
      name='water',
      gtype='LIQ',
      color={0.1,0.1,1},
      update = function(t,orx,ory)
        local x,y=orx,ory
        for _=1,waterSpeed do
          local ox,oy=0,0
          local neigh=t:neighbors(x,y)
          --t:move(x,y,x+ox,y)
          if neigh[6]==grid.nul then
            oy=1
          else
            if neigh[4]==grid.nul and neigh[8]==grid.nul then 
              ox=ox+rand(0,2)-1
            elseif neigh[4]==grid.nul then 
              ox=ox+1
            elseif neigh[8]==grid.nul then 
              ox=ox-1
            end
          end
          x=x+ox
          y=y+oy
        end
        t:move(orx,ory,x,y)
      end,
    },]]
    
    --[[
    local neigh=t:neighbors(x,y)
        if neigh[6] then
          if neigh[7]==grid.nul then
            t:move(x,y,x-1,y+1)
            return
          elseif neigh[5]==grid.nul then
            t:move(x,y,x+1,y+1)
            return
          end
        elseif neigh[6]==grid.nul then
          local neigh2=t:neighbors(x,y+1)
          local drs=1
          if fastSand and neigh2[6]==grid.nul then
            drs=2
          end
          t:move(x,y,x,y+drs)
          return
        end]]
        
        --local fastSand=true--can decrease fps old!!!  old!!!
--local waterSpeed=4  --resolution and speed (fps---)  old!!!  old!!!
--local sandIt=4  old!!!