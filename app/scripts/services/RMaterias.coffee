angular.module('myvcFrontApp')

.factory('RMaterias', ['Restangular', (Restangular) ->
	Restangular.service('materias')
])
