angular.module("myvcFrontApp")

.controller('AsignaturasCtrl', ['$scope', '$rootScope', '$interval', 'Restangular', 'RAsignaturas', 'materias', 'grupos', 'profesores', '$modal', '$filter', ($scope, $rootScope, $interval, Restangular, RAsignaturas, materias, grupos, profesores, $modal, $filter)->

	$scope.creando = false
	$scope.editando = false
	$scope.currentasignatura = {}
	$scope.currenasignaturaEdit = {}

	$scope.materias = materias
	$scope.grupos = grupos
	$scope.profesores = profesores

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid

	$scope.cancelarCrear = ()->
		$scope.creando = false

	$scope.cancelarEdit = ()->
		$scope.editando = false

	$scope.crear = ()->
		RAsignaturas.post($scope.currentasignatura).then((r)->
			$scope.gridOptions.data.push r
			$scope.cancelarCrear()
			$scope.toastr.success 'Asignatura creada con éxito'
		, (r2)->
			console.log 'No se pudo crear', r2
			$scope.toastr.error 'Error creando', 'Problema'
		)

	$scope.guardar = ()->
		Restangular.one('asignaturas/update', $scope.currentasignaturaEdit.id).customPUT($scope.currentasignaturaEdit).then((r)->
			$scope.currentasignaturaEdit.area_id = r.area_id # Para actulizar el grid
			$scope.toastr.success 'Asignatura actualizada con éxito'
			$scope.cancelarEdit()
		, (r2)->
			console.log 'No se pudo crear', r2
			$scope.toastr.error 'Error guardando', 'Problema'
		)

	$scope.editar = (row)->
		row.materia =	$filter('filter')(materias,	id: row.area_id)[0]
		row.grupo =		$filter('filter')(grupo,	id: row.grupo_id)[0]
		row.profesor =	$filter('filter')(profesor,	id: row.profesor_id)[0]

		console.log row
		$scope.currentasignaturaEdit = row
		$scope.editando = true

	$scope.eliminar = (row)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'asignaturas/removeAsignatura.tpl.html'
			controller: 'RemoveAsignaturaCtrl'
			resolve: 
				asignatura: ()->
					row
		})
		modalInstance.result.then( (asignatura)->
			$scope.gridOptions.data = $filter('filter')($scope.asignaturas, {id: '!'+asignatura.id})
			console.log 'Resultado del modal: ', asignatura
		)

	btGrid1 = '<a tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ field: 'id', type: 'number', maxWidth: 50, enableFiltering: false }
			{ name: 'edicion', displayName:'Edición', maxWidth: 40, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'orden', displayName:'Orden', type: 'number', maxWidth: 50, enableFiltering: false }
			{ field: 'materia_id',	displayName: 'Materia',		editDropdownOptionsArray: materias,		cellFilter: 'mapMaterias:grid.appScope.materias',		editableCellTemplate: 'ui-grid/dropdownEditor', editDropdownIdLabel: 'id', editDropdownValueLabel: 'materia' }
			{ field: 'grupo_id',	displayName: 'Grupos',		editDropdownOptionsArray: grupos,		cellFilter: 'mapGrupos:grid.appScope.grupos',			editableCellTemplate: 'ui-grid/dropdownEditor', editDropdownIdLabel: 'id', editDropdownValueLabel: 'nombre' }
			{ field: 'profesor_id',	displayName: 'Profesor',	editDropdownOptionsArray: profesores,	cellFilter: 'mapProfesores:grid.appScope.profesores',	editableCellTemplate: 'ui-grid/dropdownEditor', editDropdownIdLabel: 'id', editDropdownValueLabel: 'nombres' }
			{ field: 'creditos', displayName:'Créditos', type: 'number', maxWidth: 50, enableFiltering: false }
			{ name: 'nn', displayName: '', maxWidth: 20, enableSorting: false, enableFiltering: false }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue
					$scope.currentasignaturaEdit = rowEntity
					$scope.guardar()
				$scope.$apply()
			)

	

	RAsignaturas.getList().then((data)->
		$scope.gridOptions.data = data
	)
])

.filter('mapMaterias', ['$filter', ($filter)->

	return (input, materias)->
		if not input
			return 'Elija...'
		else
			mater = $filter('filter')(materias, {id: input})[0]
			return  mater.materia
])

.filter('mapGrupos', ['$filter', ($filter)->

	return (input, grupos)->
		if not input
			return 'Elija...'
		else
			grupo = $filter('filter')(grupos, {id: input})[0]
			return  grupo.nombre
])

.filter('mapProfesores', ['$filter', ($filter)->

	return (input, profesores)->
		if not input
			return 'Elija...'
		else
			profe = $filter('filter')(profesores, {id: input})[0]
			return  profe.nombres
])

.controller('RemoveAsignaturaCtrl', ['$scope', '$modalInstance', 'asignatura', 'Restangular', 'toastr', ($scope, $modalInstance, asignatura, Restangular, toastr)->
	$scope.asignatura = asignatura

	$scope.ok = ()->

		Restangular.all('asignaturas/destroy/'+asignatura.id).remove().then((r)->
			toastr.success 'asignatura '+asignatura.nombre+' eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'Problema', 'No se pudo eliminar la asignatura.'
			console.log 'Error eliminando asignatura: ', r2
		)
		$modalInstance.close(asignatura)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])