'use strict'

angular.module("myvcFrontApp")

.controller('MiActividadCtrl', ['$scope', 'App', '$rootScope', '$state', '$http', '$uibModal', '$filter', 'AuthService', 'datos', '$stateParams', 'toastr', ($scope, App, $rootScope, $state, $http, $modal, $filter, AuthService, datos, $stateParams, toastr)->

	AuthService.verificar_acceso()

	$scope.actividad_id 		= $stateParams.actividad_id 

	$scope.perfilPath 		= App.images + 'perfil/'
	$scope.views 			= App.views

	$scope.actividad 			= datos.actividad
	$scope.actividad_resuelta 	= datos.actividad_resuelta

	
	$rootScope.menucompacto = true


		


	$scope.seleccionar_opcion = (pregunta, opcion)->

		datos = 
			actividad_resuelta_id: 	$scope.actividad_resuelta.id
			pregunta_id: 			pregunta.id
			tipo_pregunta: 			pregunta.tipo_pregunta
			opcion_id: 				opcion.id
			opcion_cuadricula_id: 	null


		if $scope.actividad.one_by_one
			# Abrir un modal de confirmación para pasar a la siguiente pregunta
		else
			$http.put('::mis-actividades/seleccionar-opcion', datos).then(()->
				toastr.success 'Selección guardada'
			, ()->
				toastr.error 'No se pudo guardar selección'
			)

		for opc in pregunta.opciones
			opc.seleccionada = false
		opcion.seleccionada = true



	$scope.finalizar_actividad = ()->

		modalInstance = $modal.open({
			templateUrl: App.views + 'actividades/finalizarActividad.tpl.html'
			controller: 'FinalizarActividadCtrl'
			resolve: 
				actividad: ()->
					$scope.actividad
		})
		modalInstance.result.then( (activ)->
			$state.go 'panel.mis_actividades', {alumno_id: $scope.USER.persona_id}
		)




	return
])


.controller('FinalizarActividadCtrl', ['$scope', '$uibModalInstance', 'actividad', '$http', 'toastr', ($scope, $modalInstance, actividad, $http, toastr)->
	$scope.actividad = actividad

	$scope.ok = ()->
		$http.put('::mis-actividades/finalizar-actividad', {actividad_resuelta_id: actividad.actividad_resuelta_id}).then(()->
			toastr.info 'Has finalizado actividad'
			$modalInstance.close(actividad)
		, ()->
			toastr.error 'No se pudo guardar selección'
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


