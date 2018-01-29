angular.module("myvcFrontApp")

.controller('MateriasCtrl', ['$scope', 'toastr', '$http', 'areas', '$uibModal', '$filter', ($scope, toastr, $http, areas, $modal, $filter)->

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
		$http.post('::materias', $scope.currentmateria).then((r)->
			$scope.gridOptions.data.push r.data
			delete $scope.currentmateria
			toastr.success 'Materia creada con éxito'
		, (r2)->
			toastr.error 'Error creando', 'Problema'
		)

	$scope.guardar = ()->
		$http.put('::materias/update/'+$scope.currentmateriaEdit.id, $scope.currentmateriaEdit).then((r)->
			$scope.currentmateriaEdit.area_id = r.data.area_id # Para actulizar el grid
			delete $scope.currentmateriaEdit
			toastr.success 'Materia actualizada con éxito'
			$scope.cancelarEdit()
		, (r2)->
			toastr.error 'Error guardando', 'Problema'
		)

	$scope.editar = (row)->
		row.area = $filter('filter')(areas, id: row.area_id)[0]
		$scope.currentmateriaEdit = row
		$scope.editando = true

	$scope.eliminar = (row)->

		modalInstance = $modal.open({
			templateUrl: '==areas/removeMateria.tpl.html'
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
		multiSelect: false,
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
			}
			{ field: 'alias', displayName:'Alias' }
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
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->

				if newValue != oldValue
					$scope.currentmateriaEdit = rowEntity
					$scope.guardar()
				$scope.$apply()
			)



	$http.get('::materias').then((r)->
		$scope.gridOptions.data = r.data.materias
		$scope.areas            = r.data.mat_por_areas
		$scope.areas            = $filter('orderBy')($scope.areas, 'orden')
		for area in $scope.areas
			area.materias            = $filter('orderBy')(area.materias, 'orden')

	)




	$scope.onSortMaterias = ($item, $partFrom, $partTo, $indexFrom, $indexTo, $modeloPadre)->

		sortHash1 	= []
		sortHash2 	= []
		datos 		= {}

		console.log $partTo, $item, $modeloPadre.area

		for materia, index in $partFrom
			materia.orden = index

			hashEntry = {}
			hashEntry["" + materia.id] = index
			sortHash1.push(hashEntry)

		datos.partFrom =
			sortHash: sortHash1


		if $partFrom != $partTo
			for materia, index in $partTo
				materia.orden = index

				hashEntry = {}
				hashEntry["" + materia.id] = index
				sortHash2.push(hashEntry)

			datos.partTo =
				sortHash: sortHash2
				area_id:  $modeloPadre.area.id



		$http.put('::materias/update-orden', datos).then((r)->
			return true
		, (r2)->
			toastr.warning 'No se pudo ordenar', 'Problema'
			return false;
		)



	$scope.onSortAreas = ($item, $partFrom, $partTo, $indexFrom, $indexTo)->

		sortHash = []

		console.log $item, $partFrom, $partTo, $indexFrom, $indexTo

		for area, index in $partFrom
			area.orden = index

			hashEntry = {}
			hashEntry["" + area.id] = index
			sortHash.push(hashEntry)

		datos =
			sortHash: sortHash

		$http.put('::areas/update-orden', datos).then((r)->
			return true
		, (r2)->
			toastr.warning 'No se pudo ordenar', 'Problema'
			return false;
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

.controller('RemovemateriaCtrl', ['$scope', '$uibModalInstance', 'materia', '$http', 'toastr', ($scope, $modalInstance, materia, $http, toastr)->
	$scope.materia = materia

	$scope.ok = ()->

		$http.delete('::materias/destroy/'+materia.id).then((r)->
			toastr.success 'Materia '+materia.nombre+' eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'Problema', 'No se pudo eliminar la Materia.'
		)
		$modalInstance.close(materia)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
