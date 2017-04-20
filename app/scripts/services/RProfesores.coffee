angular.module('myvcFrontApp')


.factory('ProfesoresServ', ['$http', '$q', ($http, $q) ->

	profes = {}

	profes.profesores = []

	profes.contratos = ()->
		d = $q.defer();

		if profes.profesores.length > 0
			d.resolve profes.profesores
		else

			$http.get('::contratos').then((r)->
				profes.profesores = r.data
				d.resolve profes.profesores
			, (r2)->
				console.log 'No se trajeron los profesores contratados. ', r2
				d.reject r2.data
			)

		return d.promise

	return profes

])
