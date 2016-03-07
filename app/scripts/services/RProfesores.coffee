angular.module('myvcFrontApp')


.factory('ProfesoresServ', ['$http', '$q', ($http, $q) ->
	profesores = []

	profes = {}
	profes.contratos = ()->
		d = $q.defer();

		$http.get('::contratos').then((r)->
			d.resolve r.data
		, (r2)->
			console.log 'No se trajeron los profesores contratados. ', r2
			d.reject r2.data
		)

		return d.promise

	return profes

])
