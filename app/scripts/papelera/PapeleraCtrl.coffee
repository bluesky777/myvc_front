angular.module("myvcFrontApp")

.controller('PapeleraCtrl', ['$scope', 'App', '$rootScope', '$state', '$interval', 'Restangular', '$modal', '$filter', ($scope, App, $rootScope, $state, $interval, Restangular, $modal, $filter)->

	$scope.restaurarAlum = (alum)->
		
		Restangular.one('alumnos/restore', alum.alumno_id).customPUT().then(()->
			$scope.gridAlumnos.data = $filter('filter')($scope.gridAlumnos.data, {alumno_id: '!'+alum.alumno_id})
			$scope.toastr.success 'Éxito', 'Alumno restaurado'
		, (r2)->
			console.log 'No se pudo restaurar alumno.', alum, r2
			$scope.toastr.error 'No se restauró el alumno', 'Error'
		)
	$scope.elimAlum = (alum)->
		console.log 'Presionado para eliminar fila: ', alum

		modalInstance = $modal.open({
			templateUrl: App.views + 'papelera/forceRemoveAlumno.tpl.html'
			controller: 'ForceRemoveAlumnoCtrl'
			resolve: 
				alumno: ()->
					alum
		})
		modalInstance.result.then( (alum)->
			$scope.gridAlumnos.data = $filter('filter')($scope.gridAlumnos.data, {alumno_id: '!'+alum.alumno_id})
			console.log 'Resultado del modal: ', alum
		)

	# ALUMNOS
	btGridAlum1 = '<a class="btn btn-default btn-xs shiny info" ng-click="grid.appScope.restaurarAlum(row.entity)"><i class="fa fa-refresh "></i>Restaurar</a>'
	btGridAlum2 = '<a tooltip="¡Eliminar completamente!" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.elimAlum(row.entity)"><i class="fa fa-times "></i></a>'
	
	$scope.gridAlumnos = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'alumno_id', displayName:'Id', maxWidth: 40}
			{ name: 'edicion', displayName:'Edición', minWidth: 95, enableSorting: false, enableFiltering: false, cellTemplate: btGridAlum1 + btGridAlum2}
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
		Restangular.one('grupos/restore', grupo.id).customPUT().then(()->
			$scope.gridGrupos.data = $filter('filter')($scope.gridGrupos.data, {id: '!'+grupo.id})
			$scope.toastr.success 'Éxito', 'Grupo restaurado'
		, (r2)->
			console.log 'No se pudo restaurar grupo.', grupo, r2
			$scope.toastr.error 'No se restauró el grupo', 'Error'
		)
	$scope.elimGrupo = (grupo)->
		console.log 'Presionado para eliminar fila: ', grupo

		modalInstance = $modal.open({
			templateUrl: App.views + 'papelera/forceRemoveGrupo.tpl.html'
			controller: 'ForceRemoveGrupoCtrl'
			resolve: 
				grupo: ()->
					grupo
		})
		modalInstance.result.then( (grupo)->
			$scope.gridGrupos.data = $filter('filter')($scope.gridGrupos.data, {id: '!'+grupo.id})
			console.log 'Resultado del modal: ', grupo
		)

	btGridGrupo1 = '<a class="btn btn-default btn-xs shiny info" ng-click="grid.appScope.restaurarGrupo(row.entity)"><i class="fa fa-refresh "></i>Restaurar</a>'
	btGridGrupo2 = '<a tooltip="¡Eliminar completamente!" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.elimGrupo(row.entity)"><i class="fa fa-times "></i></a>'
	
	$scope.gridGrupos = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'id', displayName:'Id', maxWidth: 40}
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGridGrupo1 + btGridGrupo2}
			{ field: 'nombre', enableHiding: false }
			{ field: 'abrev', displayName: 'Abreviatura'}
			{ field: 'grado_id', maxWidth: 20 }
			{ field: 'titular_id', displayName:'Titular' }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi


	Restangular.all('alumnos/trashed').getList().then((data)->
		$scope.gridAlumnos.data = data;
	, (r2)->
		console.log 'No se pudo traer los alumnos eliminados.', r2
	)
	Restangular.all('grupos/trashed').getList().then((data)->
		$scope.gridGrupos.data = data;
	, (r2)->
		console.log 'No se pudo traer los grupos eliminados.', r2
	)







	# UNIDADES

	$scope.restaurarUnidad = (unidad)->
		Restangular.one('unidades/restore', unidad.id).customPUT().then(()->
			$scope.gridUnidad.data = $filter('filter')($scope.gridUnidad.data, {id: '!'+unidad.id})
			$scope.toastr.success 'Éxito', 'Unidad restaurada'
		, (r2)->
			console.log 'No se pudo restaurar unidad.', unidad, r2
			$scope.toastr.error 'No se restauró la unidad', 'Error'
		)
	$scope.elimUnidad = (unidad)->
		console.log 'Presionado para eliminar fila: ', unidad

		modalInstance = $modal.open({
			templateUrl: App.views + 'papelera/forceRemoveUnidad.tpl.html'
			controller: 'ForceRemoveUnidadCtrl'
			resolve: 
				unidad: ()->
					unidad
		})
		modalInstance.result.then( (unidad)->
			$scope.gridUnidad.data = $filter('filter')($scope.gridUnidad.data, {id: '!'+unidad.id})
			console.log 'Resultado del modal: ', unidad
		)

	btGridUnidad1 = '<a class="btn btn-default btn-xs shiny info" ng-click="grid.appScope.restaurarUnidad(row.entity)"><i class="fa fa-refresh "></i>Restaurar</a>'
	btGridUnidad2 = '<a tooltip="¡Eliminar completamente!" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.elimUnidad(row.entity)"><i class="fa fa-times "></i></a>'

	$scope.gridUnidad = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'id', displayName:'Id', maxWidth: 40}
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGridUnidad1 + btGridUnidad2}
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


	Restangular.all('unidades/trashed').getList().then((data)->
		$scope.gridUnidad.data = data;
	, (r2)->
		console.log 'No se pudo traer las unidades eliminados.', r2
	)
	Restangular.all('unidades/trashed').getList().then((data)->
		$scope.gridUnidad.data = data;
	, (r2)->
		console.log 'No se pudo traer las unidades eliminadas.', r2
	)

])
