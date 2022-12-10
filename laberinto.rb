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
  recorreCamino(resultado) 
}

def laberinto(tablero,s,t)
  nodosAbiertos = []
  nodosCerrados = []
  g = 0

  print tablero
  
  # x,y,o.
  raiz = Nodo.new(s,0,calculaH(s,s,t,tablero,nodosCerrados),nil)
  actual = raiz
  while (true) do
    # Comprobar estado
    if ( actual.estado[0] == t[0] && actual.estado[1] == t[1] )
      return actual
    end

    # Depuración
    sleep(0.1)
    printf("\nPadre: ")
    print actual.estado

    # Generar árbol 
    # Gira a la derecha
    n_estado = girar(actual.estado,0)
    actual.hijos.push(Nodo.new(n_estado,actual.g+1,calculaH(actual.estado,n_estado,t,tablero,nodosCerrados),actual))

    # Gira a la izq
    n_estado = girar(actual.estado,1)
    actual.hijos.push(Nodo.new(n_estado,actual.g+1,calculaH(actual.estado,n_estado,t,tablero,nodosCerrados),actual))

    # Avanza
    n_estado = avanzar(actual.estado)
    actual.hijos.push(Nodo.new(n_estado,actual.g+1,calculaH(actual.estado,n_estado,t,tablero,nodosCerrados),actual))

    printf("Hijos: ")
    for i in actual.hijos
      print i.estado
      nodosAbiertos.push(i)
    end

    nodosCerrados.push(actual)
    nodosAbiertos.delete(actual)
    nodosAbiertos = nodosAbiertos.compact
    actual = getOptimo(nodosAbiertos)
  end
end

# 0 derecha
# 1 abajo
# 2 izquierda
# 3 arriba
def girar(pos,grados)
  case (grados)
    when 0
      return [pos[0],pos[1],(pos[2]+1)%4]
    when 1
      return [pos[0],pos[1]-1,(pos[2]-1)%4]
  end
end

def avanzar(pos)
  case (pos[2])
    when 0
      return [pos[0]+1,pos[1],pos[2]]
    when 1
      return [pos[0],pos[1]-1,pos[2]]
    when 2
      return [pos[0]-1,pos[1],pos[2]]
    when 3
      return [pos[0],pos[1]+1,pos[2]]
  end
end

# Recordar comprobar si la posición es válida. En caso de no serlo devolver nulo o infinito
def calculaH(pre,pos,t,tablero,cerrados)
  if ( pos[0] >= tablero[0] || pos[1] >= tablero[1] || pos[0] <= 0 || pos[1] <= 0 || pos[2] < 0 || pos[2] > 3)
    return nil
  end
  if (tablero[2].include?([[pos[0],pos[1]],[pre[0],pre[1]]]) || tablero[2].include?([[pre[0],pre[1]],[pos[0],pos[1]]]))
    return nil
  end
  if (cerrados.include?(pos))
    return nil
  end
  h = ((t[0]-pos[0])+(t[1]-pos[1])-((pos[0]-pre[0])+(pos[1]-pre[1])))+(2*(pos[2]-pre[2]).abs)
  return h
end

def recorreCamino(nodo)
  while (nodo.padre != nil) do
    printf("\n #{nodo.estado}")
    nodo = nodo.padre
  end
end

def getOptimo(abiertos)
  min = abiertos[0]
  c = 1
  while (min == nil || min.h == nil)
    min = abiertos[c]
    c+=1
  end
  for i in abiertos
    if ( i.h == nil || i == nil)
      next
    elsif (min.h == nil)
      min = i
    elsif ( i.h < min.h)
      min = i
    end
  end
  return min
end

class Nodo
  @abierto # 
  attr_accessor :estado # posición
  attr_accessor :g # distancia hasta el origen
  attr_accessor :h # distancia hasta la meta
  attr_accessor :padre # anterior
  attr_accessor :hijos # siguientes
 
  def initialize(estado, g, h, padre)
    self.hijos = []
    self.estado = estado
    self.g = g
    self.h = h
    @abierto = true
  end

  def cerrar
    @abierto = false
  end

  def abierto?
    return @abierto
  end
end
