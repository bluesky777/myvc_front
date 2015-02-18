angular.module('myvcFrontApp')

.factory('RNiveles', ['Restangular', (Restangular) ->
	Restangular.service('niveles_educativos')
])


.factory('RGrados', ['Restangular', (Restangular) ->
	Restangular.service('grados')
])

.factory('RGrupos', ['Restangular', (Restangular) ->
	Restangular.service('grupos')
])

