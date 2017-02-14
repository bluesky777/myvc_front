angular.module('myvcFrontApp')
.controller('RolesCtrl', ['$scope', '$http', '$state', '$rootScope', 'AuthService', 'toastr', 'App', '$filter', ($scope, $http, $state, $rootScope, AuthService, toastr, App, $filter) ->

	AuthService.verificar_acceso()
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm


	$scope.dato = {}
	$scope.roles = []
	$scope.permissions = []

	$http.get('::roles').then((r)->
		$scope.roles = r.data
	, (r2)->
		toastr.error 'No se pudo traer los roles ', r2
	)

	$http.get('::permissions').then((r)->
		$scope.permissions = r.data
	, (r2)->
		toastr.error 'No se pudo traer los permissions ', r2
	)

	$scope.expand = (rol)->
		rol.mostrandoPermisos = true

	$scope.collapse = (rol)->
		rol.mostrandoPermisos = false

	$scope.addPermissions = (rol)->

		$http.put('::roles/addpermission/' + rol.id, {permission_id: rol.newperm.id}).then((r)->
			rol.perms.push r.data
			toastr.success 'Permiso agregado al rol ' + rol.display_name
		, (r2)->
			toastr.error 'No se pudo agregar el permiso', 'Problema'
		)

	$scope.removePermission = (rol, perm)->
		
		$http.put('::roles/removepermission/' + rol.id, {permission_id: perm.id}).then((r)->
			rol.perms = $filter('filter')(rol.perms, {id: '!'+perm.id})
			toastr.success 'Permiso eliminado del rol ' + rol.display_name
		, (r2)->
			toastr.error 'No se pudo quitar el permiso', 'Problema'
		)
])

