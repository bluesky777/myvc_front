'use strict'

angular.module("myvcFrontApp")

.controller('MiActividadCtrl', ['$scope', 'App', '$rootScope', '$state', '$http', '$uibModal', '$filter', 'AuthService', 'datos', '$stateParams', 'toastr', ($scope, App, $rootScope, $state, $http, $modal, $filter, AuthService, datos, $stateParams, toastr)->

	AuthService.verificar_acceso()

	$scope.actividad_id 		= $stateParams.actividad_id 

	$scope.perfilPath 		= App.images + 'perfil/'
	$scope.views 			= App.views

	
	$rootScope.menucompacto = true


		


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


