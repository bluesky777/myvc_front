angular.module('myvcFrontApp')

.factory('RUsers', ['Restangular', (Restangular) ->
	Restangular.service('user')
])

###
.factory('RInscripciones', ['Restangular', (Restangular) ->
	Restangular.service('inscripciones')
])


.factory('RParticipantLevel', ['Restangular', (Restangular) ->
	Restangular.service('nivel_participante')
])
###
