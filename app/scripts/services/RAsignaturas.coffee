angular.module('myvcFrontApp')

.factory('RAsignaturas', ['Restangular', (Restangular) ->
	Restangular.service('asignaturas')
])
