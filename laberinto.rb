#!/bin/ruby
=begin
  g será el camino ya recorrido
    - g será un entero que cuenta el número de casillas recorridas
  h será el camino de coste mínimo hasta t (objetivo)
    - h será un entero que cuenta el número de casillas por recorrer
    - t será un array (x,y)
  La función de evaluación será la toma de decisiones en cada momento
    - V1: decisión por cercanía a la coordenada objetivo (algoritmo A)
  El tablero va a ser un array con:
    - El tamaño (MaxX, MaxY) -eq (Columnas, Filas)
    - Una lista de pares de coordenadas indicando las paredes interiores
=end
BEGIN{
  paredes = [ [[1,3],[1,4]] , [[1,2],[2,2]] , [[2,2],[2,3]] , [[2,3],[3,3]] , [[3,3],[3,2]] , [[3,2],[4,2]], [[2,4],[3,4]] , [[2,4],[2,5]] , [[2,5],[1,5]] , [[4,1],[5,1]] , [[4,2],[5,2]] , [[4,3],[5,3]] , [[4,3],[4,4]] , [[4,4],[3,4]] , [[4,4],[4,5]] , [[5,4],[5,5]] , [[5,4],[5,3]] , [[5,3],[6,3]] , [[5,2],[6,2]] , [[2,2],[2,3]] , [[6,2],[7,2]] , [[6,3],[7,3]] , [[6,4],[7,4]] , [[6,5],[7,5]] ]
  $tablero = [7,6,paredes]
  $s = [1,4,0]
  $t = [7,4]
}
END{
  resultado = laberinto($tablero,$s,$t)
  print "\n==================\nRecorrido seguido: "
  recorreRuta(resultado)
  print "\n==================\n"
}

def laberinto(tablero,s,t)
  nodosVisitados = [] # Array de estados
  nodosAbiertos = [] # Array de punteros a nodo

  print tablero
  
  # x,y,o.
  raiz = Nodo.new(s,0,calculaH(s,s,t,tablero),nil)
  actual = raiz
  nodosAbiertos.push(actual)
  nodosVisitados.push(actual)
  while (true) do
    # Comprobar fin
    if ( actual.estado[0] == t[0] && actual.estado[1] == t[1] )
      return actual
    end
    
    n_estado = girar(actual.estado,1)
    hijo = Nodo.new(n_estado,actual.g+1,calculaH(actual.estado,n_estado,t,tablero), actual)
    if (nodosVisitados.include?(hijo.estado))
      actual.hijos[0] = nil
    else
      actual.hijos[0] = hijo
      nodosAbiertos.push(hijo)
      nodosVisitados.push(hijo.estado)
    end

    n_estado = girar(actual.estado,0)
    hijo = Nodo.new(n_estado,actual.g+1,calculaH(actual.estado,n_estado,t,tablero), actual)
    if (nodosVisitados.include?(hijo.estado))
      actual.hijos[1] = nil
    else
      actual.hijos[1] = hijo
      nodosAbiertos.push(hijo)
      nodosVisitados.push(hijo.estado)
    end

    n_estado = avanzar(actual.estado,tablero)
    if (n_estado == nil)
      actual.hijos[2] = nil
    else
      hijo = Nodo.new(n_estado,actual.g+1,calculaH(actual.estado,n_estado,t,tablero), actual)
      if (nodosVisitados.include?(hijo.estado) || nodosVisitados.include?([hijo.estado[0],hijo.estado[1],0]) || nodosVisitados.include?([hijo.estado[0],hijo.estado[1],1]) || nodosVisitados.include?([hijo.estado[0],hijo.estado[1],2]) || nodosVisitados.include?([hijo.estado[0],hijo.estado[1],3]))
        actual.hijos[2] = nil
      else
        actual.hijos[2] = hijo
        nodosAbiertos.push(hijo)
        nodosVisitados.push(hijo.estado)
      end
    end

    # Elegir nodo a explorar y cerrar el actual
    mejor = nodosAbiertos[0]
    for i in nodosAbiertos 
      if (i == nil || i.f == nil)
        next
      end
      if (i.f < mejor.f) 
        mejor = i
      end
    end

    nodosAbiertos.delete(actual)
    actual = mejor
    print "\n #{actual.estado}"
    nodosAbiertos.delete(actual)
  end
end

def recorreRuta(nodo)
  while (nodo != nil) do
    print nodo.estado
    print ":#{nodo.g} "
    nodo = nodo.padre
  end
end

def calculaH(pre, pos, t, tablero)
  return ((t[0]-pos[0])+(t[1]-pos[1])) 
end

# 0 derecha
# 1 arriba
# 2 izquierda
# 3 abajo
def girar(pos,dir)
  case (dir)
    when 0
      return [pos[0],pos[1],(pos[2]+1)%4]
    when 1
      return [pos[0],pos[1],(pos[2]-1)%4]
  end
end

def pared?(pos1,pos2,tablero)
  if (tablero[2].include?([[pos2[0],pos2[1]],[pos1[0],pos1[1]]]) || tablero[2].include?([[pos1[0],pos1[1]],[pos2[0],pos2[1]]]))
    return true
  else 
    return false
  end
end

def fuera?(pos,tablero)
  if (pos[0] > tablero[0] || pos[0] < 1 || pos[1] > tablero[1] || pos[1] < 1)
    return true
  else
    return false
  end
end

def avanzar(pos,tablero)
  case (pos[2])
    when 0
      n_pos = [pos[0]+1,pos[1],pos[2]]
    when 1
      n_pos = [pos[0],pos[1]-1,pos[2]]
    when 2
      n_pos = [pos[0]-1,pos[1],pos[2]]
    when 3
      n_pos = [pos[0],pos[1]+1,pos[2]]
  end

  if (pared?(pos,n_pos,tablero) || fuera?(n_pos,tablero))
    return nil
  else 
    return n_pos
  end
end

class Nodo
  attr_accessor :estado # posición
  attr_accessor :g # distancia hasta el origen
  attr_accessor :h # distancia hasta la meta
  attr_accessor :padre # anterior
  attr_accessor :hijos # siguientes
 
  def initialize(estado, g, h, padre)
    self.hijos = []
    self.estado = estado
    self.padre = padre
    self.g = g
    self.h = h
  end

  def f
    return (self.g + self.h)
  end
end
