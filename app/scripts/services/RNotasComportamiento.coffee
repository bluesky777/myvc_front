angular.module('myvcFrontApp')

.factory('RNotasComportamiento', ['Restangular', (Restangular) ->
	Restangular.service('notascomportamiento')
])
