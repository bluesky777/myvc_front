angular.module('myvcFrontApp')

.factory('RVotaciones', ['Restangular', (Restangular) ->
	Restangular.service('votaciones')
])

.factory('RParticipantes', ['Restangular', (Restangular) ->
	Restangular.service('participantes')
])

.factory('RAspiraciones', ['Restangular', (Restangular) ->
	Restangular.service('aspiraciones')
])

.factory('RCandidatos', ['Restangular', (Restangular) ->
	Restangular.service('candidatos')
])
