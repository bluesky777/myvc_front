angular.module('myvcFrontApp')

.factory('RImages', ['Restangular', (Restangular) ->
	Restangular.service('myimages')
])

.factory('RAskedImages', ['Restangular', (Restangular) ->
	Restangular.service('asked_images')
])
