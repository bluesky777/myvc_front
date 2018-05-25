'use strict'

angular.module("myvcFrontApp")

.controller('AcudientesCtrl', ['$scope', 'App', '$state', '$interval', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', 'uiGridConstants', ($scope, App, $state, $interval, $modal, $filter, AuthService, toastr, $http, uiGridConstants)->

	AuthService.verificar_acceso()

	$scope.dato = {}
	$scope.gridOptions = {}
	$scope.perfilPath 				= App.images+'perfil/'
	$scope.views 					= App.views
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid



	$scope.dato.grupo = ''

	$http.get('::grupos/con-paises-tipos').then((r)->

		acud_grupo = 0

		if localStorage.acud_grupo
			acud_grupo = parseInt(localStorage.acud_grupo)

		$scope.grupos 		= r.data.grupos
		$scope.paises 		= r.data.paises
		$scope.tipos_doc 	= r.data.tipos_doc

		for grupo in $scope.grupos
			if parseInt(grupo.id) == parseInt(acud_grupo)
				$scope.dato.grupo = grupo
				$scope.selectGrupo($scope.dato.grupo)

	)

	$scope.selectGrupo = (grupo)->
		localStorage.acud_grupo = grupo.id
		$scope.dato.grupo 		= grupo

		for grup in $scope.grupos
			grup.active = false

		grupo.active = true

		# Traer acudientes
		grupos_ant = []

		for grup in $scope.grupos
			if grup.orden_grado == (grupo.orden_grado - 1)
				grupos_ant.push grup


		$scope.traerAcudientes = ()->
			$http.put("::acudientes/datos", {grupo_actual: grupo}).then((r)->
				$scope.gridOptions.data 	            = r.data.acudientes

				for pariente in $scope.gridOptions.data
					pariente.fecha_nac_ant 	= pariente.fecha_nac
					pariente.fecha_nac 		= if pariente.fecha_nac then new Date(pariente.fecha_nac.replace(/-/g, '\/')) else pariente.fecha_nac

					pariente.subGridOptions.onRegisterApi = ( gridApi ) ->
						gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
							toastr.warning 'Desde aquí sólo podrás editar Acudientes', 'No guardado'
							$scope.$apply()
						)


			)

		$scope.traerAcudientes()



	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	bt2 	= '<span style="padding-left: 2px; padding-top: 4px;" class="btn-group">' + btGrid1 + btGrid2 + '</span>'
	btPazysalvo = "==directives/botonesPazysalvo.tpl.html"
	btUsuario = "==directives/botonesResetPassword.tpl.html"


	$scope.gridOptions =
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEdit: true,
		enableCellEditOnFocus: true,
		exporterSuppressColumns: [ 'edicion' ],
		exporterCsvColumnSeparator: ';',
		exporterMenuPdf: false,
		exporterMenuExcel: false,
		exporterCsvFilename: "Alumnos - MyVC.csv",
		enableGridMenu: true,
		expandableRowTemplate: '==alumnos/expandableRowTemplate.tpl.html',
		expandableRowHeight: 110,
		columnDefs: [
			{ name: 'no', displayName:'No', width: 45, enableCellEdit: false, enableColumnMenu: false, cellTemplate: '<div class="ui-grid-cell-contents">{{grid.renderContainers.body.visibleRowCache.indexOf(row)+1}}</div>'}
			{ name: 'edicion', displayName:'Edición', width: 60, enableSorting: false, enableFiltering: false, cellTemplate: bt2, enableCellEdit: false, enableColumnMenu: true}
			{ field: 'foto_nombre', displayName:'Foto', cellTemplate: "<img width=\"35px\" ng-src=\"{{grid.appScope.perfilPath + grid.getCellValue(row, col)}}\">", width: 40}
			{ field: 'nombres', minWidth: 100,
			filter: {
				condition: (searchTerm, cellValue, row)->
					entidad = row.entity
					return (entidad.nombres.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
			}
			enableHiding: false }
			{ field: 'apellidos', minWidth: 100, filter: { condition: uiGridConstants.filter.CONTAINS }}
			{ field: 'sexo', width: 60 }
			{ field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario', cellTemplate: btUsuario, minWidth: 150 }
			{ field: 'direccion', displayName: 'Dirección', minWidth: 90 }
			{ field: 'barrio', minWidth: 80 }
			{ field: 'telefono', displayName: 'Teléfono', minWidth: 90 }
			{ field: 'celular', displayName: 'Celular', minWidth: 90 }
		],
		multiSelect: false,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				if $scope.usuario_creado
					$scope.usuario_creado = false
					return

				if newValue != oldValue

					if colDef.field == "sexo"
						if newValue == 'M' or newValue == 'F'
							# Es correcto...
							$http.put('::acudientes/guardar-valor', {acudiente_id: rowEntity.id, parentesco_id: rowEntity.parentesco_id, user_id: rowEntity.user_id, propiedad: colDef.field, valor: newValue }).then((r)->
								toastr.success 'Acudiente actualizado con éxito', 'Actualizado'
							, (r2)->
								toastr.error 'Cambio no guardado', 'Error'
							)
						else
							toastr.warning 'Debe usar M o F'
							rowEntity.sexo = oldValue
					else

						$http.put('::acudientes/guardar-valor', {acudiente_id: rowEntity.id, parentesco_id: rowEntity.parentesco_id, user_id: rowEntity.user_id, propiedad: colDef.field, valor: newValue }).then((r)->
							toastr.success 'Acudiente actualizado con éxito', 'Actualizado'
						, (r2)->
							toastr.error 'Cambio no guardado', 'Error'
						)

				$scope.$apply()
			)







	$scope.eliminar = (row)->
		modalInstance = $modal.open({
			templateUrl: '==alumnos/removeAcudiente.tpl.html'
			controller: 'RemoveAcudienteCtrl'
			resolve:
				acudiente: ()->
					row
		})
		modalInstance.result.then( (acu)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+acu.id})
		, ()->
			# nada
		)


	$scope.editar = (row)->
		modalInstance = $modal.open({
			templateUrl: '==alumnos/editAcudienteModal.tpl.html'
			controller: 'EditAcudienteModalCtrl'
			resolve:
				acudiente: ()->
					row
				paises: ()->
					$scope.paises
				tipos_doc: ()->
					$scope.tipos_doc
				parentescos: ()->
					$scope.parentescos
		})
		modalInstance.result.then( (acu)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+acu.id})
		, ()->
			# nada
		)


	$scope.cambiarPazysalvo = (fila)->
		fila.pazysalvo = !fila.pazysalvo
		$http.put('::alumnos/update/' + fila.alumno_id, fila).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			fila.pazysalvo = !fila.pazysalvo
			toastr.error 'Cambio no guardado', 'Error'
		)


	$scope.resetPass = (row)->

		if !row.user_id
			toastr.warning 'Aún no tiene usuario'
			return

		modalInstance = $modal.open({
			templateUrl: App.views + 'usuarios/resetPass.tpl.html'
			controller: 'ResetPassCtrl'
			resolve:
				usuario: ()->
					row
		})
		modalInstance.result.then( (user)->
			#console.log 'Resultado del modal: ', user
		)

	$scope.traerNOAsignados = ()->
		$http.put('::acudientes/no-asignados').then((r)->
			$scope.gridOptions.data 	= r.data.acudientes

			for pariente in $scope.gridOptions.data
				pariente.fecha_nac_ant 	= pariente.fecha_nac
				pariente.fecha_nac 		  = if pariente.fecha_nac then new Date(pariente.fecha_nac.replace(/-/g, '\/')) else pariente.fecha_nac

		, ()->
			toastr.error 'No se pudo traer los acudientes sin asignar'
		)

	$scope.crearUsuario = (row)->

		if row.user_id
			toastr.warning 'Ya tiene usuario'
			return

		$http.post('::acudientes/crear-usuario', {acudiente: row}).then((r)->
			$scope.usuario_creado = true
			row.user_id 	= r.data.id
			row.username 	= r.data.username
			toastr.success 'Usuario creado'

		, ()->
			toastr.error 'No se pudo crear el usuario'
		)








	return
])




.controller('RemoveAcudienteCtrl', ['$scope', '$uibModalInstance', 'acudiente', '$http', 'toastr', 'App', ($scope, $modalInstance, acudiente, $http, toastr, App)->
	$scope.acudiente 		= acudiente
	$scope.perfilPath 	= App.images+'perfil/'

	$scope.ok = ()->

		$http.delete('::acudientes/destroy/'+acudiente.id).then((r)->
			toastr.success 'Acudiente enviado a la papelera.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo enviar a la papelera.', 'Problema'
		)
		$modalInstance.close(acudiente)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

