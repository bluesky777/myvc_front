angular.module("myvcFrontApp")

.controller('PapeleraCtrl', ['$scope', 'App', '$state', '$http', '$uibModal', '$filter', 'toastr', ($scope, App, $state, $http, $modal, $filter, toastr)->

	$scope.restaurarAlum = (alum)->
		
		$http.put('::alumnos/restore/'+alum.alumno_id).then(()->
			$scope.gridAlumnos.data = $filter('filter')($scope.gridAlumnos.data, {alumno_id: '!'+alum.alumno_id})
			toastr.success 'Éxito', 'Alumno restaurado'
		, (r2)->
			toastr.error 'No se restauró el alumno', 'Error'
		)
	$scope.elimAlum = (alum)->

		modalInstance = $modal.open({
			templateUrl: '==papelera/forceRemoveAlumno.tpl.html'
			controller: 'ForceRemoveAlumnoCtrl'
			resolve: 
				alumno: ()->
					alum
		})
		modalInstance.result.then( (alum)->
			$scope.gridAlumnos.data = $filter('filter')($scope.gridAlumnos.data, {alumno_id: '!'+alum.alumno_id})
		)

	# ALUMNOS
	btGridAlum1 = '<a class="btn btn-default btn-xs shiny info" ng-click="grid.appScope.restaurarAlum(row.entity)"><i class="fa fa-refresh "></i>Restaurar</a>'
	btGridAlum2 = '<a uib-tooltip="¡Eliminar completamente!" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.elimAlum(row.entity)"><i class="fa fa-times "></i></a>'
	
	$scope.gridAlumnos = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'alumno_id', displayName:'Id', maxWidth: 40}
			{ name: 'edicion', displayName:'Edición', maxWidth: 110, enableSorting: false, enableFiltering: false, cellTemplate: btGridAlum1 + btGridAlum2}
			{ field: 'nombres', enableHiding: false }
			{ field: 'apellidos' }
			{ field: 'sexo', maxWidth: 20 }
			{ field: 'username', displayName: 'Usuario'}
			{ field: 'fecha_nac', displayName:'Nacimiento', cellFilter: "date:mediumDate", type: 'date'}
			{ field: 'direccion', displayName: 'Dirección' }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi



	# GRUPOS

	$scope.restaurarGrupo = (grupo)->
		$http.put('::grupos/restore/'+grupo.id).then(()->
			$scope.gridGrupos.data = $filter('filter')($scope.gridGrupos.data, {id: '!'+grupo.id})
			toastr.success 'Éxito', 'Grupo restaurado'
		, (r2)->
			toastr.error 'No se restauró el grupo', 'Error'
		)
	$scope.elimGrupo = (grupo)->

		modalInstance = $modal.open({
			templateUrl: '::papelera/forceRemoveGrupo.tpl.html'
			controller: 'ForceRemoveGrupoCtrl'
			resolve: 
				grupo: ()->
					grupo
		})
		modalInstance.result.then( (grupo)->
			$scope.gridGrupos.data = $filter('filter')($scope.gridGrupos.data, {id: '!'+grupo.id})
		)

	btGridGrupo1 = '<a class="btn btn-default btn-xs shiny info" ng-click="grid.appScope.restaurarGrupo(row.entity)"><i class="fa fa-refresh "></i>Restaurar</a>'
	btGridGrupo2 = '<a uib-tooltip="¡Eliminar completamente!" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.elimGrupo(row.entity)"><i class="fa fa-times "></i></a>'
	
	$scope.gridGrupos = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'id', displayName:'Id', maxWidth: 40}
			{ name: 'edicion', displayName:'Edición', maxWidth: 110, enableSorting: false, enableFiltering: false, cellTemplate: btGridGrupo1 + btGridGrupo2}
			{ field: 'nombre', enableHiding: false }
			{ field: 'abrev', displayName: 'Abreviatura'}
			{ field: 'grado_id', maxWidth: 20 }
			{ field: 'titular_id', displayName:'Titular' }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi


	$http.get('::alumnos/trashed').then((data)->
		$scope.gridAlumnos.data = data.data;
	, (r2)->
		toastr.warning 'No se pudo traer los alumnos eliminados.'
	)
	$http.get('::grupos/trashed').then((data)->
		$scope.gridGrupos.data = data.data;
	, (r2)->
		toastr.warning 'No se pudo traer los grupos eliminados.'
	)







	# UNIDADES

	$scope.restaurarUnidad = (unidad)->
		$http.put('::unidades/restore/'+unidad.id).then(()->
			$scope.gridUnidad.data = $filter('filter')($scope.gridUnidad.data, {id: '!'+unidad.id})
			toastr.success 'Éxito', 'Unidad restaurada'
		, (r2)->
			toastr.error 'No se restauró la unidad', 'Error'
		)
	$scope.elimUnidad = (unidad)->

		modalInstance = $modal.open({
			templateUrl: '==papelera/forceRemoveUnidad.tpl.html'
			controller: 'ForceRemoveUnidadCtrl'
			resolve: 
				unidad: ()->
					unidad
		})
		modalInstance.result.then( (unidad)->
			$scope.gridUnidad.data = $filter('filter')($scope.gridUnidad.data, {id: '!'+unidad.id})
		)

	btGridUnidad1 = '<a class="btn btn-default btn-xs shiny info" ng-click="grid.appScope.restaurarUnidad(row.entity)"><i class="fa fa-refresh "></i>Restaurar</a>'
	btGridUnidad2 = '<a uib-tooltip="¡Eliminar completamente!" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.elimUnidad(row.entity)"><i class="fa fa-times "></i></a>'

	$scope.gridUnidad = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'id', displayName:'Id', maxWidth: 40}
			{ name: 'edicion', displayName:'Edición', maxWidth: 110, enableSorting: false, enableFiltering: false, cellTemplate: btGridUnidad1 + btGridUnidad2}
			{ field: 'definicion', displayName:'Definición', enableHiding: false }
			{ field: 'alias_materia', displayName: 'Materia'}
			{ field: 'abrev_grupo', displayName: 'Grupo'}
			{ field: 'numero_periodo', displayName: 'Per', maxWidth: 20 }
			{ field: 'porcentaje', displayName:'Porc' }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi


	$http.get('::unidades/trashed').then((data)->
		$scope.gridUnidad.data = data.data;
	, (r2)->
		toastr.warning 'No se pudo traer las unidades eliminados.'
	)
	$http.get('::unidades/trashed').then((data)->
		$scope.gridUnidad.data = data.data;
	, (r2)->
		toastr.warning 'No se pudo traer las unidades eliminadas.'
	)

])
