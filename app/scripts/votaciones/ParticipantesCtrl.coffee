'use strict'

angular.module("myvcFrontApp")

.controller('ParticipantesCtrl', ['$scope', '$filter', '$http', 'toastr', ($scope, $filter, $http, toastr)->

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

		$http.delete('::participantes/destroy/'+row.id).then((r)->
			toastr.success 'Se ha eliminado.'
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+r.data.id})
		, (r2)->
			toastr.error 'No se pudo eliminar.'
		)


	$scope.cambiarLocked = (row)->
		$http.put('::participantes/set-locked', {id: row.id, locked: row.locked}).then((r)->
			toastr.success 'Cambiado'
		, (r2)->
			toastr.error 'No se pudo cambiar bloqueo.'
		)


	
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	btBloq = "==votaciones/botonEventoLocked.tpl.html"
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
			


	$http.get('::participantes').then((data)->
		$scope.gridOptions.data = data.data;
	, (r2)->
		toastr.warning 'Asegúrate de tener al menos un evento como actual.'
	)

	$http.get('::grupos').then((data)->
		$scope.grupos = data.data;
	, (r2)->
		#console.log 'Error trayendo los grupos. ', r2
	)

	$http.get('::votaciones/actual').then((r)->
		$scope.votacion = r.data
	)

	$scope.inscribirGrupo = (grupo)->
		$http.post('::participantes/inscribirgrupo/' + grupo.id).then((r)->
			toastr.success 'Se inscribió el grupo.'
			grupo.presionado = true
		, (r2)->
			toastr.error 'Error al intentar inscribir grupo.'
		)


	$scope.inscribirProfesores = ()->
		$http.post('::participantes/inscribir-profesores').then((r)->
			toastr.success 'Se inscribieron los profesores.'
			btnProfPresionado = true
		, (r2)->
			toastr.error 'Error al intentar inscribir grupo.'
		)

	return
])
