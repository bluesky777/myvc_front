angular.module('myvcFrontApp')

.factory('RAlumnos', ['Restangular', (Restangular) ->
	Restangular.service('alumnos')
])
