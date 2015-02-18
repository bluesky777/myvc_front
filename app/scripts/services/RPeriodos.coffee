angular.module('myvcFrontApp')

.factory('RPeriodos', ['Restangular', (Restangular) ->
	Restangular.service('periodos')
])
