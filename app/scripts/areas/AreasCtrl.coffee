angular.module("myvcFrontApp")

.controller('AreasCtrl', ['$scope', '$rootScope', '$filter', 'Restangular', 'RAreas', '$modal', 'App', ($scope, $rootScope, $filter, Restangular, RAreas, $modal, App)->

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
		RAreas.post($scope.currentArea).then((r)->
			$scope.gridOptions.data.push r
			delete $scope.currentArea
			$scope.toastr.success 'Area creada con éxito'
		, (r2)->
			console.log 'No se pudo crear', r2
			$scope.toastr.error 'Error creando', 'Problema'
		)

	$scope.guardar = ()->
		Restangular.one('areas/update', $scope.currentAreaEdit.id).customPUT($scope.currentAreaEdit).then((r)->
			delete $scope.currentAreaEdit
			$scope.toastr.success 'Area actualizada con éxito'
			$scope.cancelarEdit()
		, (r2)->
			console.log 'No se pudo crear', r2
			$scope.toastr.error 'Error guardando', 'Problema'
		)

	$scope.editar = (row)->
		$scope.currentAreaEdit = row
		$scope.editando = true

	$scope.eliminar = (row)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'areas/removeArea.tpl.html'
			controller: 'RemoveAreaCtrl'
			resolve: 
				area: ()->
					row
		})
		modalInstance.result.then( (area)->
			$scope.gridOptions.data = $filter('filter')($scope.areas, {id: '!'+area.id})
			console.log 'Resultado del modal: ', area
		)

	btGrid1 = '<a tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
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
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue
					$scope.currentAreaEdit = rowEntity
					$scope.guardar()
				$scope.$apply()
			)

	

	RAreas.getList().then((data)->
		$scope.areas = data
		$scope.gridOptions.data = $scope.areas
	)
])

.controller('RemoveAreaCtrl', ['$scope', '$modalInstance', 'area', 'Restangular', 'toastr', ($scope, $modalInstance, area, Restangular, toastr)->
	$scope.area = area

	$scope.ok = ()->

		Restangular.all('areas/destroy/'+area.id).remove().then((r)->
			toastr.success 'Grupo '+area.nombre+' eliminado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'Problema', 'No se pudo eliminar el area.'
			console.log 'Error eliminando area: ', r2
		)
		$modalInstance.close(area)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])