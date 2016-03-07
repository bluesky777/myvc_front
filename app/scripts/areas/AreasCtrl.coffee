angular.module("myvcFrontApp")

.controller('AreasCtrl', ['$scope', 'toastr', '$filter', '$http', '$uibModal', ($scope, toastr, $filter, $http, $uibModal)->

	$scope.creando = false
	$scope.editando = false
	$scope.currentArea = {}
	$scope.currenAreaEdit = {}

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid

	$scope.cancelarCrear = ()->
		$scope.creando = false

	$scope.cancelarEdit = ()->
		$scope.editando = false

	$scope.crear = ()->
		$http.post('::areas', $scope.currentArea).then((r)->
			$scope.gridOptions.data.push r.data
			delete $scope.currentArea
			toastr.success 'Area creada con éxito'
		, (r2)->
			toastr.error 'Error creando', 'Problema'
		)

	$scope.guardar = ()->
		$http.put('::areas/update/'+$scope.currentAreaEdit.id, $scope.currentAreaEdit).then((r)->
			delete $scope.currentAreaEdit
			toastr.success 'Area actualizada con éxito'
			$scope.cancelarEdit()
		, (r2)->
			toastr.error 'Error guardando', 'Problema'
		)

	$scope.editar = (row)->
		$scope.currentAreaEdit = row
		$scope.editando = true

	$scope.eliminar = (row)->

		modalInstance = $uibModal.open({
			templateUrl: '==areas/removeArea.tpl.html'
			controller: 'RemoveAreaCtrl'
			resolve: 
				area: ()->
					row
		})
		modalInstance.result.then( (area)->
			$scope.gridOptions.data = $filter('filter')($scope.areas, {id: '!'+area.id})
		)

	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ field: 'id', type: 'number', maxWidth: 50, enableFiltering: false }
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'orden', type: 'number', maxWidth: 40, enableSorting: false }
			{ field: 'nombre', enableHiding: false, enableCellEditOnFocus: true }
			{ field: 'alias', displayName:'Alias', enableCellEditOnFocus: true }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue
					$scope.currentAreaEdit = rowEntity
					$scope.guardar()
				$scope.$apply()
			)

	

	$http.get('::areas').then((data)->
		$scope.areas = data.data
		$scope.gridOptions.data = $scope.areas
	)
])

.controller('RemoveAreaCtrl', ['$scope', '$uibModalInstance', 'area', '$http', 'toastr', ($scope, $modalInstance, area, $http, toastr)->
	$scope.area = area

	$scope.ok = ()->

		$http.delete('::areas/destroy/'+area.id).then((r)->
			toastr.success 'Grupo eliminado: '+area.nombre, 'Eliminado'
		, (r2)->
			toastr.warning 'Problema', 'No se pudo eliminar el area.'
		)
		$modalInstance.close(area)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])