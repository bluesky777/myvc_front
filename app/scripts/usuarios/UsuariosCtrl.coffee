angular.module('myvcFrontApp')
.controller('UsuariosCtrl', ['$scope', '$http', '$state', '$rootScope', 'AuthService', 'Perfil', 'App', '$uibModal', '$filter', 'toastr', ($scope, $http, $state, $rootScope, AuthService, Perfil, App, $modal, $filter, toastr) ->

	AuthService.verificar_acceso()


	$scope.editar = (row)->
		$state.go('panel.usuarios.editar', {usuario_id: row.user_id})



	$scope.crearUsuarioAdmin = ()->
		res = confirm('¿Seguro que desea crear un usuario Administrador?')
		if res
			$scope.creando = true
			$http.post('::users/crear-administrador').then((r)->
				toastr.success('Creado con éxito')
				$scope.gridOptions.data.unshift(r.data.usuario);
				$scope.creando = false
			, ()->
				toastr.error('No se pudo crear')
				$scope.creando = false
			)


	$scope.crearUsuarioPsicologo = ()->
		res = confirm('¿Seguro que desea crear un usuario Psicólogo?')
		if res
			$scope.creando = true
			$http.post('::users/crear-psicologo').then((r)->
				toastr.success('Creado con éxito')
				$scope.gridOptions.data.unshift(r.data.usuario);
				$scope.creando = false
			, ()->
				toastr.error('No se pudo crear')
				$scope.creando = false
			)


	$scope.crearUsuarioEnfermero = ()->
		res = confirm('¿Seguro que desea crear un usuario Enfermero?')
		if res
			$scope.creando = true
			$http.post('::users/crear-enfermero').then((r)->
				toastr.success('Creado con éxito')
				$scope.gridOptions.data.unshift(r.data.usuario);
				$scope.creando = false
			, ()->
				toastr.error('No se pudo crear')
				$scope.creando = false
			)


	$scope.eliminar = (row)->

		modalInstance = $modal.open({
			templateUrl: '==usuarios/removeUsuario.tpl.html'
			controller: 'RemoveUsuarioCtrl'
			resolve:
				usuario: ()->
					row
		})
		modalInstance.result.then( (user)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+user.id})
		)


	$scope.resetPass = (row)->

		modalInstance = $modal.open({
			templateUrl: '==usuarios/resetPass.tpl.html'
			controller: 'ResetPassCtrl'
			resolve:
				usuario: ()->
					row
		})
		modalInstance.result.then( (user)->
			#console.log 'Resultado del modal: ', user
		)


	$scope.verRoles = (row)->

		modalInstance = $modal.open({
			templateUrl: '==usuarios/verRoles.tpl.html'
			controller: 'VerRolesCtrl'
			resolve:
				usuario: ()->
					row
				roles: ()->
					$http.get('::roles')
		})
		modalInstance.result.then( (user)->
			#console.log 'Resultado del modal: ', user
		)

	btGrid1 = '<a uib-tooltip="No cambies roles, consulta antes" class="btn btn-default btn-xs shiny" ng-click="grid.appScope.verRoles(row.entity)">Roles</a>'
	btGrid4 = '<a uib-tooltip="Resetear contraseña" tooltip-placement="right" class="btn btn-default btn-xs shiny" ng-click="grid.appScope.resetPass(row.entity)">Cambiar password</a>'
	btGrid3 = '<a uib-tooltip="Eliminar usuario" tooltip-placement="right" ng-show="row.entity.is_superuser" class="btn btn-danger btn-xs shiny" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times"></a>'


	$scope.gridOptions =
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enableGridColumnMenu: false,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ field: 'user_id', width: 70, enableFiltering: false, enableCellEdit: false }
			{ name: 'edicion', displayName:'Edición', width: 200, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid4 + btGrid3, enableCellEdit: false}
			{ field: 'username', displayName: 'Usuario',
			filter: {
				condition: (searchTerm, cellValue, row)->
					entidad = row.entity
					if entidad.username
						return (entidad.username.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
					return false
			}
			enableHiding: false}

			{ field: 'nombres', cellTemplate: '<div>{{row.entity.nombres + " " + row.entity.apellidos}}</div>',
			filter: {
				condition: (searchTerm, cellValue, row)->
					entidad = row.entity
					if entidad.nombres
						return (entidad.nombres.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1) or (entidad.apellidos.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
					return false
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

				if newValue != oldValue

					if colDef.field == "username"
						$http.put('::perfiles/guardar-username/'+rowEntity.user_id, {username: rowEntity.username}).then((r)->
							toastr.success 'Nombre de Usuario actualizado con éxito', 'Actualizado'
						, (r2)->
							toastr.error 'Cambio no guardado', 'Error'
						)
					else
						$http.put('::perfiles/update/'+rowEntity.persona_id, rowEntity).then((r)->
							toastr.success 'Usuario actualizado con éxito', 'Actualizado'
						, (r2)->
							toastr.error 'Cambio no guardado', 'Error'
						)
				$scope.$apply()
			)


	$http.get('::perfiles/usuariosall?year_id=' + $scope.USER.year_id).then((data)->
		$scope.gridOptions.data = data.data;
	)




	$scope.crearTodosLosUsuarios = ()->
		$http.put('::perfiles/creartodoslosusuarios').then((r)->
			toastr.success 'Usuarios creados con éxito'
		, (r2)->
			toastr.error 'No se pudo crear los usuarios', 'Problema'
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


.controller('RemoveUsuarioCtrl', ['$scope', '$uibModalInstance', 'usuario', '$http', 'toastr', ($scope, $modalInstance, usuario, $http, toastr)->
	$scope.usuario = usuario

	$scope.ok = ()->

		$http.delete('::perfiles/destroy/'+usuario.user_id).then((r)->
			toastr.success 'Usuario eliminado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar al usuario.', 'Problema'
		)
		$modalInstance.close(usuario)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('ResetPassCtrl', ['$scope', '$uibModalInstance', 'usuario', '$http', 'toastr', ($scope, $modalInstance, usuario, $http, toastr)->
	$scope.usuario = usuario
	$scope.newpassword = ''
	$scope.showPassword = false

	$scope.ok = ()->

		$http.put('::perfiles/reset-password/'+usuario.user_id, {password: $scope.newpassword}).then((r)->
			toastr.success 'Contraseña cambiada.'
		, (r2)->
			toastr.warning 'No se pudo cambiar contraseña.', 'Problema'
		)
		$modalInstance.close(usuario)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


.controller('VerRolesCtrl', ['$scope', '$uibModalInstance', 'usuario', 'roles', '$http', 'toastr', ($scope, $modalInstance, usuario, roles, $http, toastr)->
	$scope.usuario = usuario
	$scope.roles = roles.data

	$scope.datos = {selecteds: []}

	$scope.datos.selecteds = usuario.roles


	$scope.seleccionando = ($item, $model)->

		$http.put('::roles/addroletouser/'+$item.id, {user_id: usuario.user_id}).then((r)->
			toastr.success 'Rol agregado con éxito.'
		, (r2)->
			toastr.warning 'No se pudo agregar el rol al usuario.', 'Problema'
		)

	$scope.quitando = ($item, $model)->

		$http.put('::roles/removeroletouser/'+$item.id, {user_id: usuario.user_id}).then((r)->
			toastr.success 'Rol quitado con éxito.'
		, (r2)->
			toastr.warning 'No se pudo quitar el rol al usuario.', 'Problema'
		)


	$scope.ok = ()->
		usuario.roles = $scope.datos.selecteds
		$modalInstance.close(usuario)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




