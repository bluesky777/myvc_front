angular.module('myvcFrontApp')

.factory('RDefinicionesComportamiento', ['Restangular', (Restangular) ->
	Restangular.service('definicionescomportamiento')
])
