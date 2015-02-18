angular.module('myvcFrontApp')

.factory('RCiudades', ['Restangular', (Restangular) ->
	Restangular.service('ciudades')
])

.factory('RPaises', ['Restangular', (Restangular) ->
	Restangular.service('paises')
])
