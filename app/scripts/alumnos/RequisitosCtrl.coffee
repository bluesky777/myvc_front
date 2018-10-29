'use strict'

angular.module("myvcFrontApp")

.controller('RequisitosCtrl', ['$scope', 'App', '$state', '$interval', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', ($scope, App, $state, $interval, $modal, $filter, AuthService, toastr, $http)->

	AuthService.verificar_acceso()
	$scope.requisitos       = []
	$scope.mostrar_crear    = false
	$scope.guardando        = false
	$scope.req_nuevo 				= {
		requisito: ''
		descripcion: ''
	}

	$http.put('::requisitos').then((r)->
		$scope.years_requisitos = r.data
	, (r2)->
		toastr.error 'No se pudo traer los requisitos'
	)

	$scope.crear_requisito = (year)->
		$scope.mostrar_crear      = true
		$scope.req_nuevo.year_id  = year.id
		$scope.req_nuevo.year     = year.year


	$scope.guardar_nuevo = ()->
		$scope.guardando = true

		$http.post('::requisitos/store', $scope.req_nuevo).then((r)->
			for requi in $scope.years_requisitos
				console.log('oNO', requi, r.data.requisito.year_id)
				if requi.id == r.data.requisito.year_id
					console.log(requi, r.data.requisito.year_id)
					requi.requisitos.push(r.data.requisito)

			$scope.mostrar_crear    = false
			$scope.guardando        = false

			$scope.req_nuevo 				= {
				requisito: ''
				descripcion: ''
			}

		, (r2)->
			toastr.error 'No se pudo crear'
			$scope.guardando        = false
		)



	$scope.guardar_cambios = (req_edit)->
		$scope.guardando = true

		$http.put('::requisitos/update', req_edit).then((r)->
			$scope.mostrar_editar     = false
			$scope.guardando          = false

		, (r2)->
			toastr.error 'No se pudo crear'
			$scope.guardando        = false
		)



	$scope.editar = (requisito, year)->
		requisito.year          = year.year
		requisito.year_id       = year.id
		$scope.mostrar_editar   = true
		$scope.req_edit         = requisito




	$scope.eliminar = (row)->
		modalInstance = $modal.open({
			templateUrl: '==alumnos/removeRequisito.tpl.html'
			controller: 'RemoveRequisitoCtrl'
			resolve:
				elemento: ()->
					row
		})
		modalInstance.result.then( (elem)->
			for requisito, index in $scope.requisitos
				if elem.id == requisito.id
					$scope.requisitos.splice(index, 1)

		, ()->
			# nada
		)


	return
])

.controller('RemoveRequisitoCtrl', ['$scope', '$uibModalInstance', 'elemento', '$http', 'toastr', 'App', ($scope, $modalInstance, elemento, $http, toastr, App)->
	$scope.elemento 		= elemento
	$scope.perfilPath 	= App.images+'perfil/'

	$scope.ok = ()->

		$http.delete('::requisitos/destroy/'+elemento.id).then((r)->
			toastr.success 'Requisito removido.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo enviar a la papelera.', 'Problema'
		)
		$modalInstance.close(elemento)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
