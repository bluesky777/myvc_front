'use strict'

angular.module("myvcFrontApp")

.controller('ParticipantesCtrl', ['$scope', '$filter', '$rootScope', 'RParticipantes', 'RGrupos', 'Restangular', 'RUsers', 'toastr', 'App', ($scope, $filter, $rootScope, RParticipantes, RGrupos, Restangular, RUsers, toastr, App)->

	$scope.editing = false
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid
	$scope.participante = {}
	btnProfPresionado = false


	$scope.votacion = {
		locked: false
		is_action: false
		fecha_inicio: ''
		fecha_fin: ''
	}

	$scope.eliminar = (row)->

		Restangular.one('participantes/destroy/'+row.id).remove().then((r)->
			toastr.success 'Se ha eliminado.'
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+r.id})
		, (r2)->
			console.log 'No se pudo eliminar.', r2
		)


	$scope.cambiarLocked = (row)->
		Restangular.one('participantes/set-locked').customPUT({id: row.id, locked: row.locked}).then((r)->
			toastr.success 'Cambiado'
		, (r2)->
			console.log 'No se pudo cambiar bloqueo.', r2
		)


	
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	btBloq = "#{App.views}votaciones/botonEventoLocked.tpl.html"
	$scope.gridOptions = 
		enableSorting: true,
		showGridFooter: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid2, enableCellEdit: false}
			{ field: 'nombres', displayName: 'nombres', enableCellEdit: false, minWidth: 80 }
			{ field: 'apellidos', displayName: 'apellidos', enableCellEdit: false }
			{ field: 'nombre_grupo', displayName: 'Grado', enableCellEdit: false }
			{ field: 'username', displayName: 'Usuario', enableCellEdit: false }
			{ field: 'votados', displayName: 'Votados', enableCellEdit: false}
			{ field: 'completo', displayName: 'Completo', enableCellEdit: false}
			{ field: 'locked', displayName: 'Bloqueado', cellTemplate: btBloq, minWidth: 80 }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			


	RParticipantes.getList().then((data)->
		$scope.gridOptions.data = data;
	, (r2)->
		toastr.warning 'Asegúrate de tener al menos un evento como actual.'
	)

	RGrupos.getList().then((data)->
		$scope.grupos = data;
	, (r2)->
		#console.log 'Error trayendo los grupos. ', r2
	)

	Restangular.one('votaciones/actual').get().then((r)->
		$scope.votacion = r
	)

	$scope.inscribirGrupo = (grupo)->
		Restangular.all('participantes/inscribirgrupo/' + grupo.id).post().then((r)->
			toastr.success 'Se inscribió el grupo.'
			grupo.presionado = true
		, (r2)->
			#console.log 'Error al intentar inscribir grupo.', r2
		)


	$scope.inscribirProfesores = ()->
		Restangular.all('participantes/inscribir-profesores').post().then((r)->
			toastr.success 'Se inscribieron los profesores.'
			btnProfPresionado = true
		, (r2)->
			#console.log 'Error al intentar inscribir grupo.', r2
		)

	return
])
