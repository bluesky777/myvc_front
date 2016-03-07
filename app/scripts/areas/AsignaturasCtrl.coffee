angular.module("myvcFrontApp")

.controller('AsignaturasCtrl', ['$scope', '$http', 'materias', 'grupos', 'profesores', '$uibModal', '$filter', 'App', 'AuthService', 'toastr', ($scope, $http, materias, grupos, profesores, $modal, $filter, App, AuthService, toastr)->

	AuthService.verificar_acceso()

	$scope.creando = false
	$scope.editando = false
	$scope.currentasignatura = {grupo: undefined, profesor: undefined}
	$scope.currenasignaturaEdit = {}

	$scope.asignaturas = []

	$scope.materias = materias
	$scope.grupos = grupos
	$scope.profesores = profesores

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid

	$scope.seleccionaGrupo = (item, model)->
		item =  if item is undefined then {id:'!'} else item
		$scope.gridOptions.data = $filter('filter')($scope.asignaturas, {grupo_id: item.id}, true)
		
		if $scope.currentasignatura.profesor != undefined
			profeSearch = $scope.currentasignatura.profesor.id
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {profesor_id: profeSearch}, true)


	$scope.seleccionaProfe = (item, model)->
		item =  if item is undefined then {profesor_id:'!'} else item
		$scope.gridOptions.data = $filter('filter')($scope.asignaturas, {profesor_id: item.id}, true)
		
		if $scope.currentasignatura.grupo != undefined
			grupoSearch = $scope.currentasignatura.grupo.id
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {grupo_id: grupoSearch}, true)


	$scope.filtrarAsignaturas = ()->

		$scope.gridOptions.data = $scope.asignaturas

		if $scope.currentasignatura.grupo != undefined
			grupoSearch = $scope.currentasignatura.grupo.id
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {grupo_id: grupoSearch}, true)

		if $scope.currentasignatura.profesor != undefined
			profeSearch = $scope.currentasignatura.profesor.id
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {profesor_id: profeSearch}, true)



	$scope.cancelarCrear = ()->
		$scope.creando = false

	$scope.cancelarEdit = ()->
		$scope.editando = false

	$scope.crear = ()->
		$http.post('::asignaturas', $scope.currentasignatura).then((r)->
			$scope.asignaturas.push r.data
			$scope.filtrarAsignaturas()
			$scope.cancelarCrear()
			toastr.success 'Asignatura creada con éxito'
		, (r2)->
			toastr.error 'Error creando', 'Problema'
		)

	$scope.guardar = ()->
		$http.put('::asignaturas/update/'+$scope.currentasignaturaEdit.id, $scope.currentasignaturaEdit).then((r)->
			$scope.currentasignaturaEdit.area_id = r.data.area_id # Para actulizar el grid
			toastr.success 'Asignatura actualizada con éxito'
			$scope.cancelarEdit()
		, (r2)->
			toastr.error 'Error guardando', 'Problema'
		)

	$scope.editar = (row)->
		row.materia =	$filter('filter')(materias,		id: row.materia_id, true)[0]
		row.grupo =		$filter('filter')(grupos,		id: row.grupo_id, true)[0]
		row.profesor =	$filter('filter')(profesores,	profesor_id: row.profesor_id, true)[0]

		$scope.currentasignaturaEdit = row
		$scope.editando = true

	$scope.eliminar = (row)->

		modalInstance = $modal.open({
			templateUrl: '==areas/removeAsignatura.tpl.html'
			controller: 'RemoveAsignaturaCtrl'
			resolve: 
				asignatura: ()->
					row
		})
		modalInstance.result.then( (asignatura)->
			$scope.asignaturas = $filter('filter')($scope.asignaturas, {id: '!'+asignatura.id})
			$scope.gridOptions.data = $scope.asignaturas
			$scope.filtrarAsignaturas()
		)

	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ field: 'id', type: 'number', width: 60, enableFiltering: false, enableCellEdit: false, enableColumnMenu: false }
			{ name: 'edicion', displayName:'Edición', width: 70, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false, enableColumnMenu: false}
			{ field: 'orden', displayName:'Orden', type: 'number', maxWidth: 50, enableFiltering: false }
			
			{ field: 'materia_id',	displayName: 'Materia',		editDropdownOptionsArray: materias,		cellFilter: 'mapMaterias:grid.appScope.materias',
			filter: {
				condition: (searchTerm, cellValue)->
					foundMaterias 	= $filter('filter')(materias, {materia: searchTerm})
					actual 			= $filter('filter')(foundMaterias, {id: cellValue}, true)
					return actual.length > 0;
			}
			editableCellTemplate: 'ui-grid/dropdownEditor', editDropdownIdLabel: 'id', editDropdownValueLabel: 'materia', enableCellEditOnFocus: true }
			
			{ field: 'grupo_id',	displayName: 'Grupos',		editDropdownOptionsArray: grupos,		cellFilter: 'mapGrupos:grid.appScope.grupos',
			filter: {
				condition: (searchTerm, cellValue)->
					foundG 	= $filter('filter')(grupos, {nombre: searchTerm})
					actual 			= $filter('filter')(foundG, {id: cellValue}, true)
					return actual.length > 0;
			}
			editableCellTemplate: 'ui-grid/dropdownEditor', editDropdownIdLabel: 'id', editDropdownValueLabel: 'nombre', enableCellEditOnFocus: true }
			
			{ field: 'profesor_id',	displayName: 'Profesor',	editDropdownOptionsArray: profesores,	cellFilter: 'mapProfesores:grid.appScope.profesores',
			filter: {
				condition: (searchTerm, cellValue)->
					foundP 	= $filter('filter')(profesores, {nombres: searchTerm, apellidos: searchTerm})
					actual 	= $filter('filter')(foundP, {profesor_id: cellValue}, true)
					return actual.length > 0;
			}
			editableCellTemplate: 'ui-grid/dropdownEditor', editDropdownIdLabel: 'id', editDropdownValueLabel: 'nombres', enableCellEditOnFocus: true }
			
			{ field: 'creditos', displayName:'Créditos', type: 'number', maxWidth: 50 }
			{ name: 'nn', displayName: '', width: 10, enableSorting: false, enableFiltering: false, enableColumnMenu: false }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue
					$scope.currentasignaturaEdit = rowEntity
					$scope.guardar()
				$scope.$apply()
			)

	

	$http.get('::asignaturas').then((data)->
		$scope.asignaturas = data.data
		$scope.gridOptions.data = $scope.asignaturas
	)
])

.filter('mapMaterias', ['$filter', ($filter)->

	return (input, materias)->
		if not input
			return 'Elija...'
		else
			mater = $filter('filter')(materias, {id: input}, true)[0]
			if mater
				return  mater.materia
			else
				return 'En papelera...'
])

.filter('mapGrupos', ['$filter', ($filter)->

	return (input, grupos)->
		if not input
			return 'Elija...'
		else
			grupo = $filter('filter')(grupos, {id: input}, true)[0]
			return  grupo.nombre
])

.filter('mapProfesores', ['$filter', ($filter)->

	return (input, profesores)->
		if not input
			return 'Elija...'
		else
			profes = $filter('filter')(profesores, {profesor_id: input}, true)

			if profes.length > 0
				return profes[0].nombres
			else
				return 'Elija...'
])

.controller('RemoveAsignaturaCtrl', ['$scope', '$uibModalInstance', 'asignatura', '$http', 'toastr', ($scope, $modalInstance, asignatura, $http, toastr)->
	$scope.asignatura = asignatura

	$scope.ok = ()->

		$http.delete('::asignaturas/destroy/'+asignatura.id).then((r)->
			toastr.success 'asignatura '+asignatura.nombre+' eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'Problema', 'No se pudo eliminar la asignatura.'
		)
		$modalInstance.close(asignatura)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])