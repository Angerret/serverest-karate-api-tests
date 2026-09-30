@usuarios @buscar
Feature: GET /usuarios/{_id} - Buscar usuario por ID
  Como administrador del sistema
  Quiero buscar un usuario específico por su ID
  Para consultar su información

  Background:
    * url baseUrl
    * def DataGenerator = Java.type('helpers.DataGenerator')
    * def idsParaLimpiar = []
    * configure afterScenario = read('classpath:helpers/limpieza.js')

  @smoke @positivo
  Scenario: Buscar un usuario existente por su ID
    * def creado = call read('classpath:common/crear-usuario.feature')
    * eval karate.appendTo('idsParaLimpiar', creado.id)
    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response == usuarioSchema
    And match response == karate.merge(creado.payload, { _id: creado.id })

  @negativo
  Scenario: Buscar un usuario con un ID que no existe
    Given path 'usuarios', DataGenerator.idInexistente()
    When method get
    Then status 400
    And match response == { message: '#(msg.usuarioNaoEncontrado)' }

  @negativo
  Scenario: Buscar un usuario con un ID de formato inválido
    Given path 'usuarios', '123'
    When method get
    Then status 400
    And match response == { id: '#(msg.idFormatoInvalido)' }
