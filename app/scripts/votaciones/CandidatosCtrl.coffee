'use strict'

angular.module("myvcFrontApp")

.controller('CandidatosCtrl', ['$scope', '$filter', 'Restangular', ($scope, $filter, Restangular)->



	$scope.aspiraciones = []
	$scope.allinscritos = []

	Restangular.all('candidatos/conaspiraciones').getList().then((r)->
		$scope.aspiraciones = r
	, (r2)->
		console.log 'No se pudo con aspiraciones. ', r2
		$scope.toastr.error 'No se pudo traer las aspiraciones', 'Problema'
	)

	Restangular.all('participantes/allinscritos').getList().then((r)->
		$scope.allinscritos = r
	, (r2)->
		console.log 'No se pudo con los inscritos. ', r2
		$scope.toastr.error 'No se pudo traer los inscritos', 'Problema'
	)

	$scope.crearCandidato = (aspiracion)->
		datos=[]
		datos.participante_id = aspiracion.newParticip.participante_id
		datos.plancha = aspiracion.newParticip.plancha
		datos.numero = aspiracion.newParticip.numero
		datos.aspiracion_id = aspiracion.id

		Restangular.all('candidatos/store').post('candidato', datos).then((r)->
			console.log 'Candidato creado.', r

			r.persona_id	= aspiracion.newParticip.persona_id
			r.nombres		= aspiracion.newParticip.nombres
			r.apellidos		= aspiracion.newParticip.apellidos
			r.user_id		= aspiracion.newParticip.user_id
			r.username		= aspiracion.newParticip.username
			r.tipo			= aspiracion.newParticip.tipo

			aspiracion.candidatos.push r
			aspiracion.newParticip = null

			$scope.toastr.success 'Candidato creado con éxito'
		, (r2)->
			if r2.error.message == 'Candidato ya inscrito.'
				$scope.toastr.warning 'Candidato ya inscrito en esta aspiración'
			else
			
				console.log 'Error al crear candidato. ', r2
				$scope.toastr.warning 'No se pudo crear el candidato', 'Problema'
		)

	$scope.eliminarCandidato = (candidato_id, aspiracion)->
		Restangular.all('candidatos/destroy/'+candidato_id).remove().then((r)->
			console.log 'Candidatura quitada.', r
			aspiracion.candidatos = $filter('filter')(aspiracion.candidatos, {candidato_id: '!'+candidato_id})
			$scope.toastr.success 'Candidato removido de la candidatura'
		, (r2)->
			console.log 'No se pudo quitar de la candidatura', r2
			$scope.toastr.error 'No se pudo quitar de la candidatura', 'Problema'
		)

	return
])
