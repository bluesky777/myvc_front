angular.module('myvcFrontApp')

.factory('RFrases', ['Restangular', (Restangular) ->
	Restangular.service('frases')
])
