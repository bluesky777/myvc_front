angular.module('myvcFrontApp')
.controller('RolesCtrl', ['$scope', 'Restangular', '$state', '$rootScope', 'AuthService', 'toastr', 'App', '$filter', ($scope, Restangular, $state, $rootScope, AuthService, toastr, App, $filter) ->

	AuthService.verificar_acceso()

	console.log 'Entra al RoleCtrl'

	$scope.dato = {}
	$scope.roles = []
	$scope.permissions = []

	Restangular.all('roles').getList().then((r)->
		$scope.roles = r
	, (r2)->
		console.log 'No se pudo traer los roles ', r2
	)

	Restangular.all('permissions').getList().then((r)->
		$scope.permissions = r
	, (r2)->
		console.log 'No se pudo traer los permissions ', r2
	)

	$scope.expand = (rol)->
		rol.mostrandoPermisos = true
		console.log 'Llega, ', rol

	$scope.collapse = (rol)->
		rol.mostrandoPermisos = false
		console.log 'colapsar, ', rol

	$scope.addPermissions = (rol)->

		Restangular.all('roles/addpermission/' + rol.id).customPUT({permission_id: rol.newperm.id}).then((r)->
			rol.perms.push r
			toastr.success 'Permiso agregado al rol ' + rol.display_name
		, (r2)->
			console.log 'No se pudo agregar el permiso ', r2
			toastr.error 'No se pudo agregar el permiso', 'Problema'
		)

	$scope.removePermission = (rol, perm)->
		
		Restangular.all('roles/removepermission/' + rol.id).customPUT({permission_id: perm.id}).then((r)->
			rol.perms = $filter('filter')(rol.perms, {id: '!'+perm.id})
			toastr.success 'Permiso eliminado del rol ' + rol.display_name
		, (r2)->
			console.log 'No se pudo quitar el permiso ', r2
			toastr.error 'No se pudo quitar el permiso', 'Problema'
		)
])

