@usuarios @listar
Feature: GET /usuarios - Listar usuarios
  Como administrador del sistema
  Quiero obtener la lista de usuarios
  Para conocer los usuarios registrados en la base de datos

  Background:
    * url baseUrl
    * def DataGenerator = Java.type('helpers.DataGenerator')
    * def idsParaLimpiar = []
    * configure afterScenario = read('classpath:helpers/limpieza.js')

  @smoke @positivo
  Scenario: Obtener la lista de todos los usuarios
    Given path 'usuarios'
    When method get
    Then status 200
    And match response == listaUsuariosSchema
    And match response.quantidade == karate.sizeOf(response.usuarios)
    And assert responseTime < 10000

  @positivo
  Scenario: Un usuario recién registrado aparece en la lista filtrada por email
    * def nuevoUsuario = DataGenerator.usuario(false)
    * def creado = call read('classpath:common/crear-usuario.feature') { datosUsuario: '#(nuevoUsuario)' }
    * eval karate.appendTo('idsParaLimpiar', creado.id)
    Given path 'usuarios'
    And param email = nuevoUsuario.email
    When method get
    Then status 200
    And match response == listaUsuariosSchema
    And match response.quantidade == 1
    And match response.usuarios[0] == karate.merge(nuevoUsuario, { _id: creado.id })

  @positivo
  Scenario: Filtrar la lista para obtener solo administradores
    * def creado = call read('classpath:common/crear-usuario.feature') { datosUsuario: '#(DataGenerator.usuario(true))' }
    * eval karate.appendTo('idsParaLimpiar', creado.id)
    Given path 'usuarios'
    And param administrador = 'true'
    When method get
    Then status 200
    And match response == listaUsuariosSchema
    And match each response.usuarios contains { administrador: 'true' }

  @negativo
  Scenario: Filtrar por un email que no existe devuelve una lista vacía
    Given path 'usuarios'
    And param email = DataGenerator.email()
    When method get
    Then status 200
    And match response == { quantidade: 0, usuarios: [] }

  @negativo
  Scenario: Filtrar con un valor inválido para administrador
    Given path 'usuarios'
    And param administrador = 'si'
    When method get
    Then status 400
    And match response == { administrador: '#(msg.administradorInvalido)' }
