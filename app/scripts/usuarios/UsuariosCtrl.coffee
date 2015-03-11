angular.module('myvcFrontApp')
.controller('UsuariosCtrl', ['$scope', '$http', 'Restangular', '$state', '$rootScope', 'AuthService', 'Perfil', 'App', '$modal', '$filter', 'RolesServ', ($scope, $http, Restangular, $state, $rootScope, AuthService, Perfil, App, $modal, $filter, RolesServ) ->

	AuthService.verificar_acceso()


	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$state.go('panel.usuarios.editar', {alumno_id: row.alumno_id})

	$scope.eliminar = (row)->
		console.log 'Presionado para eliminar fila: ', row

		modalInstance = $modal.open({
			templateUrl: App.views + 'usuarios/removeUsuario.tpl.html'
			controller: 'RemoveUsuarioCtrl'
			resolve: 
				usuario: ()->
					row
		})
		modalInstance.result.then( (user)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+user.id})
			console.log 'Resultado del modal: ', user
		)


	$scope.resetPass = (row)->
		console.log 'Presionado para resetear pass: ', row

		modalInstance = $modal.open({
			templateUrl: App.views + 'usuarios/resetPass.tpl.html'
			controller: 'ResetPassCtrl'
			resolve: 
				usuario: ()->
					row
		})
		modalInstance.result.then( (user)->
			console.log 'Resultado del modal: ', user
		)


	$scope.verRoles = (row)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'usuarios/verRoles.tpl.html'
			controller: 'VerRolesCtrl'
			resolve: 
				usuario: ()->
					row
				roles: ()->
					RolesServ.getRoles()
		})
		modalInstance.result.then( (user)->
			console.log 'Resultado del modal: ', user
		)

	btGrid1 = '<a class="btn btn-default btn-xs shiny" ng-click="grid.appScope.verRoles(row.entity)">Roles</a>'
	btGrid2 = '<a tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid3 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	btGrid4 = '<a tooltip="Resetear contraseña" tooltip-placement="right" class="btn btn-default btn-xs shiny" ng-click="grid.appScope.resetPass(row.entity)">Reset pass</a>'
	

	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'user_id', width: 70, enableFiltering: false, enableCellEdit: false }
			{ name: 'edicion', displayName:'Edición', width: 200, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2 + btGrid3 + btGrid4, enableCellEdit: false}
			{ field: 'username', displayName: 'Usuario', 
			filter: {
				condition: (searchTerm, cellValue, row)->
					entidad = row.entity
					return (entidad.username.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
			}
			enableHiding: false}
			
			{ field: 'nombres', cellTemplate: '<div>{{row.entity.nombres + " " + row.entity.apellidos}}</div>', 
			filter: {
				condition: (searchTerm, cellValue, row)->
					entidad = row.entity
					return (entidad.nombres.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1) or (entidad.apellidos.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
				}
			}

			{ field: 'sexo', width: 70 }
			
			{ field: 'roles', displayName: 'Roles', enableCellEdit: false, cellFilter: 'mapRoles', 
			filter: {
				condition: (searchTerm, cellValue)->
					found = $filter('filter')(cellValue, {name: searchTerm})
					return found.length>0
				}
			}
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue

					if colDef.field == "username"
						Restangular.one('perfiles/guardarusername', rowEntity.user_id).customPUT({username: rowEntity.username}).then((r)->
							$scope.toastr.success 'Nombre de Usuario actualizado con éxito', 'Actualizado'
						, (r2)->
							$scope.toastr.error 'Cambio no guardado', 'Error'
							console.log 'Falló al intentar guardar: ', r2
						)
					else
						Restangular.one('perfiles/update', rowEntity.persona_id).customPUT(rowEntity).then((r)->
							$scope.toastr.success 'Usuario actualizado con éxito', 'Actualizado'
						, (r2)->
							$scope.toastr.error 'Cambio no guardado', 'Error'
							console.log 'Falló al intentar guardar: ', r2
						)
				$scope.$apply()
			)

	
	Restangular.all('perfiles/usuariosall').getList().then((data)->
		$scope.gridOptions.data = data;
	)




	$scope.crearTodosLosUsuarios = ()->
		Restangular.one('perfiles/creartodoslosusuarios').customPUT().then((r)->
			console.log 'Usuarios creados, ', r
			$scope.toastr.success 'Usuarios creados con éxito'
		, (r2)->
			console.log 'No se pudo crear los usuarios, ', r2
			$scope.toastr.error 'No se pudo crear los usuarios', 'Problema'
		)

])

.filter('mapRoles', ['$filter', ($filter)->

	return (input, grados)->

		if not input
			return ''
		else

			roles = []

			angular.forEach input, (value, key) ->
				roles.push value.name

			roles = roles.join()
			return  roles
])


.controller('RemoveUsuarioCtrl', ['$scope', '$modalInstance', 'usuario', 'Restangular', 'toastr', ($scope, $modalInstance, usuario, Restangular, toastr)->
	$scope.usuario = usuario

	$scope.ok = ()->

		Restangular.all('perfiles/destroy/'+usuario.user_id).remove().then((r)->
			toastr.success 'Usuario eliminado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar al usuario.', 'Problema'
			console.log 'Error eliminando usuario: ', r2
		)
		$modalInstance.close(usuario)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('ResetPassCtrl', ['$scope', '$modalInstance', 'usuario', 'Restangular', 'toastr', ($scope, $modalInstance, usuario, Restangular, toastr)->
	$scope.usuario = usuario

	$scope.ok = ()->

		Restangular.one('perfiles/cambiarpassword/'+usuario.user_id).customPUT({password: $scope.newpassword}).then((r)->
			toastr.success 'Contraseña cambiada.'
		, (r2)->
			toastr.warning 'No se pudo cambiar contraseña.', 'Problema'
			console.log 'Error cambiando contraseña: ', r2
		)
		$modalInstance.close(usuario)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


.controller('VerRolesCtrl', ['$scope', '$modalInstance', 'usuario', 'roles', 'Restangular', 'toastr', ($scope, $modalInstance, usuario, roles, Restangular, toastr)->
	$scope.usuario = usuario
	$scope.roles = roles

	$scope.datos = {selecteds: []}

	$scope.datos.selecteds = usuario.roles


	$scope.seleccionando = ($item, $model)->
		console.log $scope.datos.selecteds, $item

		Restangular.one('roles/addroletouser/'+$item.id).customPUT({user_id: usuario.user_id}).then((r)->
			toastr.success 'Rol agregado con éxito.'
		, (r2)->
			toastr.warning 'No se pudo agregar el rol al usuario.', 'Problema'
			console.log 'No se pudo agregar el rol al usuario.: ', r2
		)

	$scope.quitando = ($item, $model)->
		console.log $item, $model

		Restangular.one('roles/removeroletouser/'+$item.id).customPUT({user_id: usuario.user_id}).then((r)->
			toastr.success 'Rol quitado con éxito.'
		, (r2)->
			toastr.warning 'No se pudo quitar el rol al usuario.', 'Problema'
			console.log 'No se pudo quitar el rol al usuario.: ', r2
		)


	$scope.ok = ()->
		usuario.roles = $scope.datos.selecteds
		$modalInstance.close(usuario)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




