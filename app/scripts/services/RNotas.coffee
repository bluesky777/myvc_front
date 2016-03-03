angular.module('myvcFrontApp')

.factory('NotasServ', ['Restangular', '$q', (Restangular, $q) ->
	notas = {}

	notas.detalladas = (asignatura_id)->
		d = $q.defer();

		Restangular.all('notas/detailed/' + asignatura_id).getList().then((r)->
			d.resolve r
		, (r2)->
			console.log 'No se trajeron las notas. ', r2
			d.reject r2
		)

		return d.promise

	return notas

])

.factory('EscalasValorativasServ', ['Restangular', '$q', (Restangular, $q) ->
	escalas = []

	escalasr = {}
	
	escalasr.escalas = (asignatura_id)->
		d = $q.defer();

		if escalas.length > 0
			d.resolve escalas
		else
			Restangular.all('escalas').getList().then((r)->
				escalas = r
				d.resolve escalas
			, (r2)->
				console.log 'No se trajeron las escalas. ', r2
				d.reject r2
			)

		return d.promise

	return escalasr

])

.factory('AusenciasServ', ['Restangular', '$q', (Restangular, $q) ->
	ausencias = {}

	ausencias.detalladas = (asignatura_id)->
		d = $q.defer();

		Restangular.one('ausencias/detailed', asignatura_id).get().then((r)->
			d.resolve r
		, (r2)->
			console.log 'No se trajeron las ausencias. ', r2
			d.reject r2
		)

		return d.promise

	return ausencias

])

.factory('ComportamientoServ', ['Restangular', '$q', (Restangular, $q) ->
	comportamientos = {}

	comportamientos.detallados = (grupo_id)->
		d = $q.defer();

		Restangular.one('nota_comportamiento/detailed', grupo_id).get().then((r)->
			d.resolve r
		, (r2)->
			console.log 'No se trajeron los comportamientos. ', r2
			d.reject r2
		)

		return d.promise

	return comportamientos

])
