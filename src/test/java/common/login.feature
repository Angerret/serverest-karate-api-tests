@ignore
Feature: Helper reutilizable - Iniciar sesión y obtener el token
  Uso:
    * def sesion = call read('classpath:common/login.feature') { credenciales: { email: '...', password: '...' } }
  Devuelve: sesion.token

  Scenario: Login
    Given url baseUrl
    And path 'login'
    And request credenciales
    When method post
    Then status 200
    * def token = response.authorization
