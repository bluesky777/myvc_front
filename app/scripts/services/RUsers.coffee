angular.module('myvcFrontApp')

.factory('RUsers', ['Restangular', (Restangular) ->
	Restangular.service('user')
])

.factory('RolesServ', ['Restangular', '$q', (Restangular, $q) ->
	
	roles = []

	interfaz = {
		getRoles: ()->
			d = $q.defer()

			console.log 'roles.length', roles.length
			if roles.length > 0
				d.resolve(roles)
			else
				Restangular.all('roles').getList().then((r)->
					roles = r
					d.resolve(roles)
				, (r2)->
					d.reject(r2)
				)

			return d.promise

			
	}
	return interfaz;
])



###
.factory('RInscripciones', ['Restangular', (Restangular) ->
	Restangular.service('inscripciones')
])


.factory('RParticipantLevel', ['Restangular', (Restangular) ->
	Restangular.service('nivel_participante')
])
###
