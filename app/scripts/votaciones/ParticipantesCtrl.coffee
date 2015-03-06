'use strict'

angular.module("myvcFrontApp")

.controller('ParticipantesCtrl', ['$scope', '$filter', '$rootScope', 'RParticipantes', 'RGrupos', 'Restangular', 'RUsers', ($scope, $filter, $rootScope, RParticipantes, RGrupos, Restangular, RUsers)->

	$scope.editing = false
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid
	$scope.participante = {}
	$scope.participanteEdit = {}
	$scope.grupoInscribir = {grupo: {}}

	$scope.votacion = {
		locked: false
		is_action: false
		fecha_inicio: ''
		fecha_fin: ''
	}

	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$scope.editing = true
		$scope.participanteEdit = row

	$scope.eliminar = (row)->

		Restangular.one('participantes/destroy/'+row.id).remove().then((r)->
			console.log 'Se ha eliminado: ', r
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+r.id})
			$scope.actualizarUsuarios()
		, (r2)->
			console.log 'No se pudo eliminar.', r2
		)

	btGrid1 = '<a tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'nombres', displayName: 'nombres', enableCellEdit: false }
			{ field: 'apellidos', displayName: 'apellidos', enableCellEdit: false }
			{ field: 'username', displayName: 'Usuario', enableCellEdit: false }
			{ field: 'votados', displayName: 'Votados', enableCellEdit: false}
			{ field: 'completo', displayName: 'Completo', enableCellEdit: false}
			{ field: 'locked', displayName: 'Bloqueado'}
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue
					Restangular.one('participantes/update', rowEntity.id).customPUT(rowEntity).then((r)->
						$scope.toastr.success 'Participante actualizado con éxito', 'Actualizado'
					, (r2)->
						$scope.toastr.error 'Cambio no guardado', 'Error'
						console.log 'Falló al intentar guardar: ', r2
					)
				$scope.$apply()
			)

	RParticipantes.getList().then((data)->
		$scope.gridOptions.data = data;
	, (r2)->
		console.log 'Error trayendo las aspiraciones. ', r2
	)

	RGrupos.getList().then((data)->
		$scope.grupos = data;
	, (r2)->
		console.log 'Error trayendo los grupos. ', r2
	)

	$scope.actualizarUsuarios = ()->

		Restangular.one('votaciones/unsignedsusers').get().then((data)->
			$scope.usuarios = data;
		, (r2)->
			console.log 'Error trayendo los usuarios. ', r2
		)
	$scope.actualizarUsuarios()

	Restangular.one('votaciones/actual').get().then((r)->
		$scope.votacion = r
	)

	$scope.crear = ()->
		console.log 'Datos a guardar: ', $scope.participante
		RParticipantes.post($scope.participante).then((r)->
			console.log 'Se hizo el post del participante: ', r
			$scope.gridOptions.data.push r
			$scope.usuarios = $filter('filter')($scope.usuarios, {id: '!'+r.user_id})
			$scope.participante.user = null
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)

	$scope.guardar = ()->
		da = $scope.participanteEdit
		dato = 
			id: da.id
			user_id: da.user_id
			votacion_id: da.votacion_id
			locked: da.locked
			intentos: da.intentos

		Restangular.one('participantes/update', dato.id).put(dato).then((r)->
			console.log 'Se hizo el put del participante. ', r
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)

	$scope.inscribirGrupo = ()->
		Restangular.all('participantes/inscribirgrupo/' + $scope.grupoInscribir.grupo.id).post().then((r)->
			console.log 'Se inscribió el grupo. ', r
		, (r2)->
			console.log 'Error al intentar inscribir grupo.', r2
		)

	return
])
