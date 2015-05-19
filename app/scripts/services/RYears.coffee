angular.module('myvcFrontApp')

.factory('RYears', ['Restangular', (Restangular) ->
	Restangular.service('years')
])

.factory('RPeriodos', ['Restangular', (Restangular) ->
	Restangular.service('periodos')
])
