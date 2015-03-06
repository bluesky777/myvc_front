angular.module('myvcFrontApp')

.factory('RAreas', ['Restangular', (Restangular) ->
	Restangular.service('areas')
])

.factory('RMaterias', ['Restangular', (Restangular) ->
	Restangular.service('materias')
])
