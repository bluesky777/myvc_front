angular.module('myvcFrontApp')

.factory('RProfesores', ['Restangular', (Restangular) ->
	Restangular.service('profesores')
])


.factory('ProfesoresServ', ['Restangular', '$q', (Restangular, $q) ->
	profesores = []

	profes = {}
	profes.contratos = ()->
		d = $q.defer();

		Restangular.all('contratos').getList().then((r)->
			d.resolve r
		, (r2)->
			console.log 'No se trajeron los profesores contratados. ', r2
			d.reject r2
		)

		return d.promise

	return profes

])
