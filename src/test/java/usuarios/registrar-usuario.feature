@usuarios @registrar
Feature: POST /usuarios - Registrar usuario
  Como administrador del sistema
  Quiero registrar nuevos usuarios
  Para mantener actualizada la base de datos de usuarios

  Background:
    * url baseUrl
    * def DataGenerator = Java.type('helpers.DataGenerator')
    * def idsParaLimpiar = []
    * configure afterScenario = read('classpath:helpers/limpieza.js')

  @smoke @positivo
  Scenario: Registrar un usuario administrador con datos válidos
    * def payload = DataGenerator.usuario(true)
    Given path 'usuarios'
    And request payload
    When method post
    Then status 201
    And match response == creacionSchema
    And match response.message == msg.cadastroSucesso
    * def id = response._id
    * eval karate.appendTo('idsParaLimpiar', id)
    # Verificación: el usuario quedó guardado con los datos enviados
    Given path 'usuarios', id
    When method get
    Then status 200
    And match response == usuarioSchema
    And match response == karate.merge(payload, { _id: id })

  @positivo
  Scenario Outline: Registrar un usuario con perfil administrador = <administrador>
    * def payload = DataGenerator.usuario('<administrador>' == 'true')
    Given path 'usuarios'
    And request payload
    When method post
    Then status 201
    And match response == creacionSchema
    * eval karate.appendTo('idsParaLimpiar', response._id)
    Given path 'usuarios', response._id
    When method get
    Then status 200
    And match response.administrador == '<administrador>'

    Examples:
      | administrador |
      | true          |
      | false         |

  @negativo
  Scenario: No se permite registrar un usuario con un email ya registrado
    * def existente = call read('classpath:common/crear-usuario.feature')
    * eval karate.appendTo('idsParaLimpiar', existente.id)
    * def duplicado = DataGenerator.usuario(false)
    * set duplicado.email = existente.payload.email
    Given path 'usuarios'
    And request duplicado
    When method post
    Then status 400
    And match response == { message: '#(msg.emailEmUso)' }

  @negativo @data-driven
  Scenario Outline: No se registra un usuario con datos inválidos - <caso>
    * def payload = DataGenerator.usuario(true)
    * if (accion == 'remover') karate.remove('payload', '$.' + campo)
    * if (accion == 'reemplazar') karate.set('payload', '$.' + campo, valor)
    Given path 'usuarios'
    And request payload
    When method post
    Then status 400
    * def mensajeObtenido = response[campo]
    And match mensajeObtenido == mensaje

    Examples:
      | read('classpath:data/usuarios-invalidos.json') |
