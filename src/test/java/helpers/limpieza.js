function fn() {
  // afterScenario hook: deletes the users created during the scenario,
  // even if the scenario failed, so no junk data is left in the API.
  var ids = karate.get('idsParaLimpiar');
  if (!ids || karate.sizeOf(ids) === 0) return;
  karate.set('idsParaLimpiar', []);
  karate.forEach(ids, function (id) {
    karate.call('classpath:common/eliminar-usuario.feature', { id: id });
  });
}
