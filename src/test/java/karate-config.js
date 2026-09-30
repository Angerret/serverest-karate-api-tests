function fn() {
  // Environment: dev (public ServeRest) by default, or local (ServeRest on your machine)
  var env = karate.env || 'dev';

  var urls = {
    dev: 'https://serverest.dev',
    local: 'http://localhost:3000'
  };

  var config = {
    env: env,
    baseUrl: karate.properties['baseUrl'] || urls[env] || urls.dev,

    // Expected API messages (centralized so they are not hardcoded in the features)
    msg: karate.read('classpath:data/mensajes.json'),

    // Reusable JSON schemas
    usuarioSchema: karate.read('classpath:schemas/usuario-schema.json'),
    listaUsuariosSchema: karate.read('classpath:schemas/lista-usuarios-schema.json'),
    creacionSchema: karate.read('classpath:schemas/creacion-schema.json'),
    mensajeSchema: karate.read('classpath:schemas/mensaje-schema.json')
  };

  karate.log('Ambiente:', env, '| baseUrl:', config.baseUrl);

  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 30000);
  karate.configure('headers', { Accept: 'application/json' });
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  return config;
}
