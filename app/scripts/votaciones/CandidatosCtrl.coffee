'use strict'

angular.module("myvcFrontApp")

.controller('CandidatosCtrl', ['$scope', '$filter', '$http', 'toastr', ($scope, $filter, $http, toastr)->



	$scope.aspiraciones = []
	$scope.allinscritos = []

	$http.get('::candidatos/conaspiraciones').then((r)->
		$scope.aspiraciones = r.data
	, (r2)->
		toastr.error 'No se pudo traer las aspiraciones', 'Problema'
	)

	$http.get('::participantes/allinscritos').then((r)->
		$scope.allinscritos = r.data
	, (r2)->
		toastr.error 'No se pudo traer los inscritos', 'Problema'
	)

	$scope.crearCandidato = (aspiracion)->
		datos = {}
		datos.participante_id = aspiracion.newParticip.participante_id
		datos.plancha = aspiracion.newParticip.plancha
		datos.numero = aspiracion.newParticip.numero
		datos.aspiracion_id = aspiracion.id


		$http.post('::candidatos/store/candidato', datos).then((r)->
			r = r.data

			r.persona_id	= aspiracion.newParticip.persona_id
			r.nombres		= aspiracion.newParticip.nombres
			r.apellidos		= aspiracion.newParticip.apellidos
			r.user_id		= aspiracion.newParticip.user_id
			r.username		= aspiracion.newParticip.username
			r.tipo			= aspiracion.newParticip.tipo

			aspiracion.candidatos.push r
			aspiracion.newParticip = null

			toastr.success 'Candidato creado con éxito'
		, (r2)->
			if r2.data.error.message == 'Candidato ya inscrito'
				toastr.warning 'Candidato ya inscrito en esta aspiración'
			else
				toastr.warning 'No se pudo crear el candidato', 'Problema'
		)

	$scope.eliminarCandidato = (candidato_id, aspiracion)->
		$http.delete('::candidatos/destroy/'+candidato_id).then((r)->
			aspiracion.candidatos = $filter('filter')(aspiracion.candidatos, {candidato_id: '!'+candidato_id})
			toastr.success 'Candidato removido de la candidatura'
		, (r2)->
			toastr.error 'No se pudo quitar de la candidatura', 'Problema'
		)

	return
])
