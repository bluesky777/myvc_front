angular.module('myvcFrontApp')

.factory('RNotas', ['Restangular', (Restangular) ->
	Restangular.service('notas')
])
