'use strict'

angular.module("myvcFrontApp")

.controller('EditarPreguntaCtrl', ['$scope', 'App', '$rootScope', '$state', '$http', '$uibModal', '$filter', 'AuthService', 'datos', 'toastr', '$stateParams', '$location', '$anchorScroll', '$timeout', ($scope, App, $rootScope, $state, $http, $modal, $filter, AuthService, datos, toastr, $stateParams, $location, $anchorScroll, $timeout)->

	AuthService.verificar_acceso()

	$scope.pregunta_id 		= $stateParams.pregunta_id

	$scope.perfilPath 		= App.images + 'perfil/'
	$scope.views 			= App.views

	$scope.pregunta = datos
	

	$scope.editor_options = 
		allowedContent: true,
		entities: false


	$timeout ()->
		$location.hash('scroll-pregunta');
		$anchorScroll();

	$scope.onEditorReady = ()->
		console.log 'Editor listo'


	$scope.guardar_cambios = (opcion)->

		$http.put('::opciones/guardar', opcion ).then((r)->
			r = r.data
			toastr.success 'Cambios guardados'
		(r2)->
			toastr.error 'No se pudo guardar cambios'
		)


	$scope.restar = (modelo)->
		if $scope.pregunta[modelo] > 0
			$scope.pregunta[modelo] = $scope.pregunta[modelo] - 1
	$scope.sumar = (modelo)->
		if $scope.pregunta[modelo] < 1000
			$scope.pregunta[modelo] = parseInt($scope.pregunta[modelo]) + 1

	$scope.cancelar = ()->
		$state.go('panel.editar_actividad', { actividad_id: $scope.pregunta.actividad_id })


	$scope.add_opcion = ()->
		cant = $scope.pregunta.opciones.length

		opcion = 
			definicion: 	'Opcion ' + (cant+1)
			orden: 			cant
			pregunta_id: 	$scope.pregunta.id
			is_correct: 	false			

		$http.put('::opciones/add-opcion', opcion ).then((r)->
			r = r.data
			toastr.success 'Opción agregada'
			
			$scope.pregunta.opciones.push(r)
		(r2)->
			toastr.error 'No se pudo agregar'
		)


	$scope.setOpcionCorrect = (opcion)->

		$http.put('::opciones/set-opcion-correct', opcion ).then((r)->
			r = r.data
			for opc in $scope.pregunta.opciones
				opc.is_correct = if opcion==opc then true else false
		(r2)->
			toastr.error 'No se pudo establecer correcta'
		)


	$scope.eliminarOpcion = (opcion)->

		$http.delete('::opciones/destroy/'+opcion.id ).then((r)->
			r = r.data
			toastr.success 'Opción eliminada'
			$scope.pregunta.opciones = $filter('filter')($scope.pregunta.opciones, {id: '!'+opcion.id})
		(r2)->
			toastr.error 'No se pudo establecer correcta'
		)




	return
])


