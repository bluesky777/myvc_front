'use strict'

angular.module("myvcFrontApp")

.controller('EditarActividadCtrl', ['$scope', 'App', '$rootScope', '$state', '$http', '$uibModal', '$filter', 'AuthService', 'datos', 'toastr', '$stateParams', '$timeout', ($scope, App, $rootScope, $state, $http, $modal, $filter, AuthService, datos, toastr, $stateParams, $timeout)->

	AuthService.verificar_acceso()

	$scope.actividad_id 		= $stateParams.actividad_id

	$scope.perfilPath 		= App.images + 'perfil/'
	$scope.views 			= App.views

	$scope.actividad = datos.actividad

	if $scope.actividad.finaliza_at
		$scope.actividad.finaliza_at = new Date($scope.actividad.finaliza_at)
	else
		$scope.actividad.finaliza_at = new Date()
	
	if $scope.actividad.inicia_at
		$scope.actividad.inicia_at = new Date($scope.actividad.inicia_at)
	else
		$scope.actividad.inicia_at = new Date()
	
	$scope.editor_options = 
		allowedContent: true,
		entities: false



	$scope.restar = (modelo)->
		if $scope.actividad[modelo] > 0
			$scope.actividad[modelo] = $scope.actividad[modelo] - 1
	$scope.sumar = (modelo)->
		if $scope.actividad[modelo] < 1000
			$scope.actividad[modelo] = parseInt($scope.actividad[modelo]) + 1

	$scope.onEditorReady = ()->
		console.log 'Editor listo'

	addZero = (i)->
		if (i < 10)
			i = "0" + i;
		return i;


	$scope.ftime_to_string = (ftime)->
		h = addZero(ftime.getHours());
		m = addZero(ftime.getMinutes());
		s = addZero(ftime.getSeconds());
		d = ftime.yyyymmdd();
		res = d + "T" + h + ":" + m + ":" + s + ".000Z";

	$scope.guardarActividad = (salir)->
		finaliza_at 	= $scope.ftime_to_string($scope.actividad.finaliza_at)
		$scope.actividad.finaliza_at_str 	= finaliza_at
		inicia_at 		= $scope.ftime_to_string($scope.actividad.inicia_at)
		$scope.actividad.inicia_at_str 		= inicia_at

		$http.put('::actividades/guardar', $scope.actividad ).then((r)->
			r = r.data
			toastr.success 'Cambios guardados'
			
			if salir
				$state.go('panel.actividades', { asign_id: $scope.actividad.asignatura_id })

		(r2)->
			toastr.error 'No se pudo guardar cambios'
		)



	$scope.editar_pregunta = (pregunta)->
		$state.go('panel.editar_actividad', { actividad_id: $scope.actividad.id })
		localStorage.pregunta_edit = JSON.stringify(pregunta)
		
		$timeout ()->
			$state.go 'panel.editar_actividad.pregunta'

		
	$scope.crearPregunta = ()->
		datos = 
			actividad_id: $scope.actividad_id

		$http.post('::preguntas/crear', datos ).then((r)->
			r = r.data
			$scope.actividad.preguntas.push r
			$scope.editar_pregunta(r)
		(r2)->
			toastr.error 'No se pudo crear pregunta'
		)

	$scope.cambios_pregunta_guardados = (preg_editada)->
		for preg in $scope.actividad.preguntas
			if preg.id == preg_editada.id
				preg = preg_editada

		
	return
])


