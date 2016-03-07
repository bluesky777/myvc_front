angular.module('myvcFrontApp')

.factory('NotasServ', ['$http', '$q', ($http, $q) ->
	notas = {}

	notas.detalladas = (asignatura_id)->
		d = $q.defer();

		$http.get('::notas/detailed/' + asignatura_id).then((r)->
			d.resolve r.data
		, (r2)->
			d.reject r2
		)

		return d.promise

	return notas

])

.factory('EscalasValorativasServ', ['$http', '$q', ($http, $q) ->
	escalas = []

	escalasr = {}
	
	escalasr.escalas = (asignatura_id)->
		d = $q.defer();

		if escalas.length > 0
			d.resolve escalas
		else
			$http.get('::escalas').then((r)->
				escalas = r.data
				d.resolve escalas
			, (r2)->
				d.reject r2
			)

		return d.promise

	return escalasr

])

.factory('AusenciasServ', ['$http', '$q', ($http, $q) ->
	ausencias = {}

	ausencias.detalladas = (asignatura_id)->
		d = $q.defer();

		$http.get('ausencias/detailed/'+asignatura_id).then((r)->
			d.resolve r.data
		, (r2)->
			d.reject r2
		)

		return d.promise

	return ausencias

])

.factory('ComportamientoServ', ['$http', '$q', ($http, $q) ->
	comportamientos = {}

	comportamientos.detallados = (grupo_id)->
		d = $q.defer();

		$http.get('nota_comportamiento/detailed/'+grupo_id).then((r)->
			d.resolve r.data
		, (r2)->
			d.reject r2
		)

		return d.promise

	return comportamientos

])
