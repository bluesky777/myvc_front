angular.module('myvcFrontApp')

.factory('Perfil', ['App', '$q', '$cookies', '$http', (App, $q, $cookies, $http) ->

	user = {}

	setUser: (usuario) ->
		user = usuario

	User: ->
		return user


	save: ->
		user.save()
	id: ->
		user.user_id
	idioma: ->
		user.idioma_system

	setImagen: (imagen_id, imagen_nombre)->
		user.imagen_id = imagen_id
		user.imagen_nombre = imagen_nombre
	setOficial: (foto_id, foto_nombre)->
		user.foto_id = foto_id
		user.foto_nombre =foto_nombre
	nameToShow: ()->
		if user.tipo == 'Usuario'
			return user.username.toUpperCase()
		else
			return user.nombres + ' ' + user.apellidos

	deleteUser: ()->
		user = {}

])