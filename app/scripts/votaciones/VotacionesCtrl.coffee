'use strict'

angular.module("myvcFrontApp")

.controller('VotacionesCtrl', ['$scope', '$filter', '$rootScope', 'RVotaciones', 'Restangular', 'resolved_user', 'App', ($scope, $filter, $rootScope, RVotaciones, Restangular, resolved_user, App)->


	$scope.data = {} # Para el popup del Datapicker
	$scope.editing = false
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid
	$scope.votacionEdit = {}

	$scope.votacion = {
		locked: false
		is_action: false
		fecha_inicio: ''
		fecha_fin: ''
	}

	$scope.dateOptions = {
		startingDay: 1
	}

	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$scope.editing = true
		$scope.votacionEdit = row

	$scope.eliminar = (row)->
		Restangular.all('votaciones/destroy/'+row.id).remove().then((r)->
			console.log 'Se ha eliminado: ', r
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+row.id}) ;
		, (r2)->
			console.log 'No se pudo eliminar.', r2
		)

	$scope.cambiarInAction = (row)->
		Restangular.one('votaciones/set-in-action').customPUT({id: row.id}).then((r)->
			console.log 'Se ha puesto en acción: ', r
		, (r2)->
			console.log 'No se pudo poner en acción.', r2
		)


	$scope.cambiarLocked = (row)->
		Restangular.one('votaciones/set-locked').customPUT({id: row.id}).then((r)->
			console.log 'Se ha bloqueado: ', r
		, (r2)->
			console.log 'No se pudo bloquear.', r2
		)

	$scope.cambiarEventoActual = (row)->
		Restangular.one('votaciones/set-actual').customPUT({id: row.id}).then((r)->
			console.log 'Se ha vuelto actual: ', r
		, (r2)->
			console.log 'No se pudo volver actual.', r2
		)



	btGrid1 = '<a tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	btActual = "#{App.views}votaciones/botonEventoActual.tpl.html"
	btBloq = "#{App.views}votaciones/botonEventoLocked.tpl.html"
	btAccion = "#{App.views}votaciones/botonEventoInAction.tpl.html"

	$scope.gridOptions = 
		enableSorting: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'nombre', enableHiding: false }
			{ field: 'locked', displayName: 'Bloqueado', maxWidth: 60, cellTemplate: btBloq }
			{ field: 'actual', displayName: 'Actual', maxWidth: 60, cellTemplate: btActual}
			{ field: 'in_action', displayName: 'En acción', maxWidth: 60, cellTemplate: btAccion }
			{ field: 'fecha_inicio', displayName:'Inicia', cellFilter: "date:mediumDate", type: 'date', maxWidth: 80}
			{ field: 'fecha_fin', displayName: 'Termina', cellFilter: "date:mediumDate", type: 'date', maxWidth: 80 }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi

	RVotaciones.getList().then((data)->
		$scope.gridOptions.data = data;
	, (r2)->
		console.log 'Error trayendo los eventos. ', r2
	)

	$scope.crear = ()->
		Restangular.all('votaciones/store').post($scope.votacion).then((r)->
			console.log 'Se hizo el post de la votación', r

			if r.actual
				angular.forEach($scope.gridOptions.data, (value, key)->
					value.actual = 0
				)
				
			$scope.gridOptions.data.push r

		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)

	$scope.guardar = ()->
		$scope.votacionEdit.put().then((r)->
			console.log 'Se hizo el put de la votación', r
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)


	return
])