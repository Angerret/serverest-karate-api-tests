@usuarios @e2e
Feature: Flujo CRUD completo de un usuario
  Como administrador del sistema
  Quiero gestionar el ciclo de vida completo de un usuario
  Para administrar la base de datos de usuarios de punta a punta

  Background:
    * url baseUrl
    * def DataGenerator = Java.type('helpers.DataGenerator')
    * def idsParaLimpiar = []
    * configure afterScenario = read('classpath:helpers/limpieza.js')

  @smoke
  Scenario: Registrar, consultar, actualizar y eliminar un usuario
    # 1. Registrar
    * def usuario = DataGenerator.usuario(true)
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 201
    And match response == creacionSchema
    * def id = response._id
    * eval karate.appendTo('idsParaLimpiar', id)

    # 2. Consultar
    Given path 'usuarios', id
    When method get
    Then status 200
    And match response == karate.merge(usuario, { _id: id })

    # 3. Actualizar
    * def cambios = DataGenerator.usuario(false)
    Given path 'usuarios', id
    And request cambios
    When method put
    Then status 200
    And match response.message == msg.alteracaoSucesso

    Given path 'usuarios', id
    When method get
    Then status 200
    And match response == karate.merge(cambios, { _id: id })

    # 4. Eliminar
    Given path 'usuarios', id
    When method delete
    Then status 200
    And match response.message == msg.exclusaoSucesso

    Given path 'usuarios', id
    When method get
    Then status 400
    And match response.message == msg.usuarioNaoEncontrado
