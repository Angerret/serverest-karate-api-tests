@ignore
Feature: Helper reutilizable - Registrar un usuario
  Uso:
    * def creado = call read('classpath:common/crear-usuario.feature')
    * def creado = call read('classpath:common/crear-usuario.feature') { datosUsuario: '#(miUsuario)' }
  Devuelve: creado.id y creado.payload

  Scenario: Registrar usuario y devolver su ID
    * def DataGenerator = Java.type('helpers.DataGenerator')
    * def payload = karate.get('datosUsuario', DataGenerator.usuario(true))
    Given url baseUrl
    And path 'usuarios'
    And request payload
    When method post
    Then status 201
    * def id = response._id
