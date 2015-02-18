angular.module('myvcFrontApp')

.factory('RUnidades', ['Restangular', (Restangular) ->
	Restangular.service('unidades')
])
