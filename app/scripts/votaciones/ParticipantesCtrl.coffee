'use strict'

angular.module("myvcFrontApp")

.controller('ParticipantesCtrl', ['$scope', '$filter', '$http', 'toastr', ($scope, $filter, $http, toastr)->

	$scope.editing			= false
	$scope.gridScope		= $scope # Para getExternalScopes de ui-Grid
	$scope.participante		= {}
	btnProfPresionado 		= false


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



	$http.put('::participantes/datos').then((data)->
		data = data.data
		$scope.gridOptions.data = data.participante;
		$scope.grupos 			= data.grupos;
		$scope.votacion 		= data.votacion;
		$scope.datos.grupo_profes_acudientes = data.partic_gr;
	, (r2)->
		toastr.warning 'Asegúrate de tener al menos un evento como actual.'
	)



	$scope.guardarInscripciones = ()->
		$scope.guardando_inscrip = true
		$http.put('::participantes/guardar-inscripciones', {grupos: $scope.grupos}).then((r)->
			toastr.success 'Inscripciones guardadas.'
			$scope.guardando_inscrip = false
		, (r2)->
			toastr.error 'Error al intentar guardar Inscripciones.'
			$scope.guardando_inscrip = false
		)

	return
])
