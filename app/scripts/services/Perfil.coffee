angular.module('myvcFrontApp')

.factory('Perfil', ['RUsers', 'Restangular', 'App', '$q', '$cookies', '$rootScope', 'AUTH_EVENTS', '$http', (RUsers, Restangular, App, $q, $cookies, $rootScope, AUTH_EVENTS, $http) ->

	user = {}

	setUser: (usuario) ->
		user = usuario

	User: ->
		return user


	save: ->
		user.save()
	id: ->
		user.id
	idioma: ->
		user.idioma_system

	setImagen: (imagen_id, imagen_nombre)->
		user.imagen_id = imagen_id
		user.imagen_nombre = imagen_nombre
	setOficial: (foto_id, foto_nombre)->
		user.foto_id = foto_id
		user.foto_nombre =foto_nombre
		

])