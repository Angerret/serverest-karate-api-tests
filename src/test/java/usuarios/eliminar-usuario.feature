@usuarios @eliminar
Feature: DELETE /usuarios/{_id} - Eliminar usuario
  Como administrador del sistema
  Quiero eliminar usuarios
  Para mantener depurada la base de datos

  Background:
    * url baseUrl
    * def DataGenerator = Java.type('helpers.DataGenerator')
    * def idsParaLimpiar = []
    * configure afterScenario = read('classpath:helpers/limpieza.js')

  @smoke @positivo
  Scenario: Eliminar un usuario existente
    * def creado = call read('classpath:common/crear-usuario.feature')
    Given path 'usuarios', creado.id
    When method delete
    Then status 200
    And match response == mensajeSchema
    And match response.message == msg.exclusaoSucesso
    # Verificación: el usuario ya no existe
    Given path 'usuarios', creado.id
    When method get
    Then status 400
    And match response == { message: '#(msg.usuarioNaoEncontrado)' }

  @negativo
  Scenario: Eliminar un usuario con un ID que no existe
    Given path 'usuarios', DataGenerator.idInexistente()
    When method delete
    Then status 200
    And match response == { message: '#(msg.nenhumExcluido)' }

  @negativo @carrito
  Scenario: No se permite eliminar un usuario que tiene un carrito registrado
    # Preparación: usuario administrador con sesión, un producto propio y un carrito
    * def admin = DataGenerator.usuario(true)
    * def creado = call read('classpath:common/crear-usuario.feature') { datosUsuario: '#(admin)' }
    * eval karate.appendTo('idsParaLimpiar', creado.id)
    * def sesion = call read('classpath:common/login.feature') { credenciales: { email: '#(admin.email)', password: '#(admin.password)' } }
    * def token = sesion.token

    Given path 'produtos'
    And header Authorization = token
    And request DataGenerator.producto()
    When method post
    Then status 201
    * def idProducto = response._id

    Given path 'carrinhos'
    And header Authorization = token
    And request { produtos: [ { idProduto: '#(idProducto)', quantidade: 1 } ] }
    When method post
    Then status 201

    # Acción y validación
    Given path 'usuarios', creado.id
    When method delete
    Then status 400
    And match response == { message: '#(msg.exclusaoComCarrinho)', idCarrinho: '#string' }

    # Limpieza específica: cancelar el carrito y eliminar el producto
    Given path 'carrinhos', 'cancelar-compra'
    And header Authorization = token
    When method delete
    Then status 200
    Given path 'produtos', idProducto
    And header Authorization = token
    When method delete
    Then status 200
