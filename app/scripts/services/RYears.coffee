angular.module('myvcFrontApp')

.factory('RYears', ['Restangular', (Restangular) ->
	Restangular.service('years')
])
