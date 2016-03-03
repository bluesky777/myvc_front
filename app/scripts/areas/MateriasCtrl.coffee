angular.module("myvcFrontApp")

.controller('MateriasCtrl', ['$scope', '$rootScope', 'toastr', 'Restangular', 'areas', '$uibModal', '$filter', 'App', ($scope, $rootScope, toastr, Restangular, areas, $modal, $filter, App)->

	$scope.creando = false
	$scope.editando = false
	$scope.currentmateria = {}
	$scope.currenmateriaEdit = {}
	$scope.areas = areas

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid

	$scope.cancelarCrear = ()->
		$scope.creando = false

	$scope.cancelarEdit = ()->
		$scope.editando = false

	$scope.crear = ()->
		Restangular.one('materias').customPOST($scope.currentmateria).then((r)->
			$scope.gridOptions.data.push r
			delete $scope.currentmateria
			toastr.success 'Materia creada con éxito'
		, (r2)->
			toastr.error 'Error creando', 'Problema'
		)

	$scope.guardar = ()->
		Restangular.one('materias/update', $scope.currentmateriaEdit.id).customPUT($scope.currentmateriaEdit).then((r)->
			$scope.currentmateriaEdit.area_id = r.area_id # Para actulizar el grid
			delete $scope.currentmateriaEdit
			toastr.success 'Materia actualizada con éxito'
			$scope.cancelarEdit()
		, (r2)->
			toastr.error 'Error guardando', 'Problema'
		)

	$scope.editar = (row)->
		row.area = $filter('filter')(areas, id: row.area_id)[0]
		console.log row
		$scope.currentmateriaEdit = row
		$scope.editando = true

	$scope.eliminar = (row)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'areas/removeMateria.tpl.html'
			controller: 'RemovemateriaCtrl'
			resolve: 
				materia: ()->
					row
		})
		modalInstance.result.then( (materia)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+materia.id})
		)

	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ field: 'id', type: 'number', maxWidth: 50, enableFiltering: false }
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'materia', enableHiding: false, 
			filter: {
				condition: (searchTerm, cellValue, row)->
					foundG 	= $filter('filter')($scope.gridOptions.data, {materia: searchTerm})
					actual 	= $filter('filter')(foundG, {materia: cellValue})
					return actual.length > 0;
			}
			enableCellEditOnFocus: true }
			{ field: 'alias', displayName:'Alias', enableCellEditOnFocus: true }
			{ field: 'area_id', displayName: 'Area', editDropdownOptionsArray: areas, cellFilter: 'mapAreas:grid.appScope.areas', editableCellTemplate: 'ui-grid/dropdownEditor', 
			filter: {
				condition: (searchTerm, cellValue)->
					foundG 	= $filter('filter')($scope.areas, {nombre: searchTerm})
					actual 	= $filter('filter')(foundG, {id: cellValue}, true)
					return actual.length > 0;
			}
			editDropdownIdLabel: 'id', editDropdownValueLabel: 'nombre' }
			{ name: 'nn', displayName: '', maxWidth: 20, enableSorting: false, enableFiltering: false }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue
					$scope.currentmateriaEdit = rowEntity
					$scope.guardar()
				$scope.$apply()
			)

	

	Restangular.one('materias').getList().then((data)->
		$scope.gridOptions.data = data
	)
])

.filter('mapAreas', ['$filter', ($filter)->

	return (input, areas)->
		if not input
			return 'Elija...'
		else
			area = $filter('filter')(areas, {id: input})[0]
			if area
				return  area.nombre
			else
				return 'Elija...'
])

.controller('RemovemateriaCtrl', ['$scope', '$uibModalInstance', 'materia', 'Restangular', 'toastr', ($scope, $modalInstance, materia, Restangular, toastr)->
	$scope.materia = materia

	$scope.ok = ()->

		Restangular.all('materias/destroy/'+materia.id).remove().then((r)->
			toastr.success 'Materia '+materia.nombre+' eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'Problema', 'No se pudo eliminar la Materia.'
		)
		$modalInstance.close(materia)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])