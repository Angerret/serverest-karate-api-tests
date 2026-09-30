@usuarios @actualizar
Feature: PUT /usuarios/{_id} - Actualizar usuario
  Como administrador del sistema
  Quiero actualizar la información de un usuario existente
  Para mantener sus datos correctos

  Background:
    * url baseUrl
    * def DataGenerator = Java.type('helpers.DataGenerator')
    * def idsParaLimpiar = []
    * configure afterScenario = read('classpath:helpers/limpieza.js')

  @smoke @positivo
  Scenario: Actualizar la información de un usuario existente
    * def creado = call read('classpath:common/crear-usuario.feature')
    * eval karate.appendTo('idsParaLimpiar', creado.id)
    * def datosActualizados = DataGenerator.usuario(false)
    Given path 'usuarios', creado.id
    And request datosActualizados
    When method put
    Then status 200
    And match response == mensajeSchema
    And match response.message == msg.alteracaoSucesso
    # Verificación: los cambios quedaron guardados
    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response == usuarioSchema
    And match response == karate.merge(datosActualizados, { _id: creado.id })

  @positivo
  Scenario: Actualizar un ID inexistente registra un nuevo usuario
    # Comportamiento documentado de ServeRest: el PUT sobre un ID inexistente crea el registro
    * def datos = DataGenerator.usuario(true)
    Given path 'usuarios', DataGenerator.idInexistente()
    And request datos
    When method put
    Then status 201
    And match response == creacionSchema
    And match response.message == msg.cadastroSucesso
    * eval karate.appendTo('idsParaLimpiar', response._id)

  @negativo
  Scenario: No se permite actualizar un usuario con el email de otro usuario
    * def usuarioA = call read('classpath:common/crear-usuario.feature')
    * def usuarioB = call read('classpath:common/crear-usuario.feature')
    * eval karate.appendTo('idsParaLimpiar', usuarioA.id)
    * eval karate.appendTo('idsParaLimpiar', usuarioB.id)
    * def datos = DataGenerator.usuario(false)
    * set datos.email = usuarioB.payload.email
    Given path 'usuarios', usuarioA.id
    And request datos
    When method put
    Then status 400
    And match response == { message: '#(msg.emailEmUso)' }

  @negativo
  Scenario Outline: No se actualiza un usuario sin el campo obligatorio <campo>
    * def creado = call read('classpath:common/crear-usuario.feature')
    * eval karate.appendTo('idsParaLimpiar', creado.id)
    * def datos = DataGenerator.usuario(true)
    * remove datos.<campo>
    Given path 'usuarios', creado.id
    And request datos
    When method put
    Then status 400
    And match response.<campo> == '<mensaje>'

    Examples:
      | campo    | mensaje                |
      | nome     | nome é obrigatório     |
      | email    | email é obrigatório    |
      | password | password é obrigatório |
