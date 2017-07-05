'use strict'

angular.module("myvcFrontApp")

.controller('RespuestasCtrl', ['$scope', 'App', '$rootScope', '$state', '$http', '$uibModal', '$filter', 'AuthService', 'datos', '$stateParams', 'toastr', ($scope, App, $rootScope, $state, $http, $modal, $filter, AuthService, datos, $stateParams, toastr)->

	AuthService.verificar_acceso()

	$scope.actividad_id 		= $stateParams.actividad_id 

	$scope.perfilPath 		= App.images + 'perfil/'
	$scope.views 			= App.views

	$scope.actividad 			= datos.actividad
	$rootScope.menucompacto = true



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


