
local grid={}

grid.nul=nil -- (не менять для powderbox) >:( --значение пустых клеток (по умолч)
grid.invalid='__invalid__' --значение неверных клеток

function grid.new(w,h) --создать новую сетку сшириной w и высотой h
  local ret = {}
  ret.w = w --ширина
  ret.h = h --высота
  ret.grid={} --Создаем таблицу в которой бутет хранится сетка
  
  for i=1,w do --Создаем и заполняем 2хмерный массив (сетка)
    ret.grid[i]={}
    for j=1,h do
      ret.grid[i][j]=grid.nul
    end
  end
  
  -----------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------
  
  function ret:isValid(x,y)--есть ли клетка в сетке (находится ли она за его пределами?)
    local val=self.grid[x][y]
    if val==grid.invalid or x>self.w or y>self.h or x<1 or y<1 then
      return false
    else
      return true
    end
  end
  
  function ret:set(x,y,v)--Задать значение клетки (с проверкой)
    if self:isValid(x,y) then
      rawset(self.grid[x],y,v) --rawset нужен для обхода метаметода __newindex ( self.grid[x][y]=v )
      return true --возвращаем true если клетка была успешно записана
    end
  end
  
  function ret:get(x,y) --Получить значение клетки (с проверкой)
    if self:isValid(x,y) then
      return self.grid[x][y] --Возвращаем значение клетки
    end
  end
  
  function ret:getNeighborXY(x,y,n)
    if n==1 then
      return x-1, y-1
    elseif n==2 then
      return x  , y-1
    elseif n==3 then
      return x+1, y-1
    elseif n==4 then 
      return x+1, y  
    elseif n==5 then 
      return x+1, y+1
    elseif n==6 then
      return x  , y+1
    elseif n==7 then  
      return x-1, y+1
    elseif n==8 then  
      return x-1, y  
    end
  end
  
  function ret:neighbors(x,y,n) --Получить "соседей" клетки
    --[1][2][3]
    --[8][ ][4]
    --[7][6][5]
    return{
      self:get(x-1, y-1) or n,
      self:get(x  , y-1) or n,
      self:get(x+1, y-1) or n,
      self:get(x+1, y  ) or n,
      self:get(x+1, y+1) or n,
      self:get(x  , y+1) or n,
      self:get(x-1, y+1) or n,
      self:get(x-1, y  ) or n,
    }
  end
  
  function ret:move(x,y,nx,ny)
    if not(x==nx and y==ny) then
      self:set( nx, ny, self:get(x, y))
      self:set( x , y ,  grid.nul  )
    end
  end
  
  function ret:swap(x1,y1,x2,y2)
    local a = self:get(x1,y1)
    local b = self:get(x2,y2)
    self:set(x1,y1,b)
    self:set(x2,y2,a)
  end
  
  function ret:flow(x,y,xv,yv,max)
    xv=math.max(math.min(xv,1),-1)
    yv=math.max(math.min(yv,1),-1)
    local retx,rety,reti,test
    for i=1,max do
      local potx,poty = x+(i*xv),y+(i*yv)
      if self:get(potx,poty)==grid.nul then
        retx,rety,reti=potx,poty,i
        test=true
      else 
        break
      end
    end
    if test then
      self:move(x,y,retx,rety)
      return retx,rety,reti
    else
      return x,y,nil
    end
  end
  
  setmetatable(ret.grid,{ --задаем стандартное значение таблицы (метатаблица)
      __index = function() return grid.invalid end 
  })
  
  return ret
end

setmetatable(grid, {__call=grid.new}) --При попытке вызвать таблицу ( grid() ) будет вызвана функция grid.new

return grid