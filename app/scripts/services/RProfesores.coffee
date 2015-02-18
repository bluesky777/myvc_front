angular.module('myvcFrontApp')

.factory('RProfesores', ['Restangular', (Restangular) ->
	Restangular.service('profesores')
])
