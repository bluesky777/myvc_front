'use strict'

angular.module("myvcFrontApp")

.controller('MisActividadesCtrl', ['$scope', 'App', '$rootScope', '$state', '$http', '$uibModal', '$filter', 'AuthService', 'datos', '$stateParams', 'toastr', ($scope, App, $rootScope, $state, $http, $modal, $filter, AuthService, datos, $stateParams, toastr)->

	AuthService.verificar_acceso()

	$scope.grupo_id 			= $stateParams.grupo_id # Puede que solo esté este
	$scope.asign_id 			= $stateParams.asign_id # o solo este
	$scope.grupos 				= datos.grupos
	$scope.otras_asignaturas 	= datos.otras_asignaturas
	$scope.mis_asignaturas 		= datos.mis_asignaturas

	$scope.perfilPath 		= App.images + 'perfil/'
	$scope.views 			= App.views

	
	$rootScope.menucompacto = true


	if $stateParams.asign_id

		for asign in $scope.mis_asignaturas
			if asign.asignatura_id == parseInt($scope.asign_id)
				$scope.actividades 		= asign.actividades
				$scope.asignatura 		= asign

	$scope.crear = (asignatura_id)->
		$http.post('::actividades/crear', { asignatura_id: asignatura_id }).then((r)->
			r = r.data
			toastr.success 'Actividad creada', 'Ahora a editar'
			$state.go('panel.editar_actividad', {actividad_id: r.id})
		, (r2)->
			toastr.error 'No se pudo crear actividad.', 'Error'
		)
		


	$scope.eliminarActividad = (row, asignatura)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'actividades/removeActividad.tpl.html'
			controller: 'RemoveActividadCtrl'
			resolve: 
				actividad: ()->
					row
		})
		modalInstance.result.then( (activ)->
			asignatura.actividades = $filter('filter')(asignatura.actividades, {id: '!'+activ.id})
		)




	return
])


.controller('RemoveActividadCtrl', ['$scope', '$uibModalInstance', 'actividad', '$http', 'toastr', ($scope, $modalInstance, actividad, $http, toastr)->
	$scope.actividad = actividad

	$scope.ok = ()->

		$http.delete('::actividades/destroy/'+actividad.id).then((r)->
			toastr.success 'Actividad enviada a la papelera.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo enviar a la papelera.', 'Problema'
		)
		$modalInstance.close(actividad)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


