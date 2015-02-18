angular.module('myvcFrontApp')

.factory('RSubUnidades', ['Restangular', (Restangular) ->
	Restangular.service('subunidades')
])
