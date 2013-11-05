require 'rspec'

class ComparadorBinario
  def initialize(un_resultado_esperado)
    @esperado = un_resultado_esperado
  end
end

class MayorA < ComparadorBinario
  def compararCon(un_resultado_obtenido)
    un_resultado_obtenido > @esperado
  end
end

class IgualA < ComparadorBinario
  def compararCon(un_resultado_obtenido)
    un_resultado_obtenido == @esperado
  end
end

class DescripcionBuilder
  def siendo(&valores)
    @valores = valores.call()
  end
  def esperar(&expectativas)
    @expectativas = expectativas
  end
  def evaluar()
    @valores.each do |valor|
      valor.instance_eval(&@expectativas)
    end
  end
end

class Object
  def deberia(comparador)
    raise Exception unless comparador.compararCon(self)
  end

  def ser(comparador)
    comparador
  end

  def igual_a(resultado_esperado)
    IgualA.new(resultado_esperado)
  end

  def mayor_a(resultado_esperado)
    MayorA.new(resultado_esperado)
  end

  def describir(nombre_spec, &descripcion)
    builder = DescripcionBuilder.new
    builder.instance_eval(&descripcion)
    builder.evaluar()
  end
end

describe 'xspec' do
  it 'puede describir una asercion' do
    1.deberia ser igual_a 1
  end

  it 'puede correr una asercion que falla' do
    expect {
      ser(2).deberia ser igual_a ser(1)
    }.to raise_error(Exception)
  end

  it 'puede correr una asercion que falla' do
    expect {
      (2 + 5).deberia ser mayor_a 10
    }.to raise_error(Exception)
  end

  it 'puede correr una prueba con un set de valores' do
    describir 'mayoria de numeros' do
      siendo do
         [5,
          3,
          8]
      end
      esperar do
        self.deberia ser mayor_a 2
      end
    end
  end

  it 'puede correr una prueba con un set de valores que falla' do
    expect {describir 'mayoria de numeros' do
      siendo do
        [5,
         3,
         8]
      end
      esperar do
        self.deberia ser mayor_a 4
      end
    end}.to raise_error Exception
  end

  #it 'puede correr una prueba con un set de valores' do
  #  describir 'suma de numeros' do
  #    siendo do
  #      [{x: 2, y:3, z:5},
  #       {x: 1, y:2, z:3}]
  #    end
  #    esperar do |fixture|
  #      (fixture.x + fixture.y).deberia ser igual_a fixture.z
  #    end
  #  end
  #end
end