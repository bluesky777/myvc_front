angular.module('myvcFrontApp')
.controller('UsuariosCtrl', ['$scope', '$http', 'Restangular', '$state', '$rootScope', 'AuthService', 'Perfil', 'App', ($scope, $http, Restangular, $state, $rootScope, AuthService, Perfil, App) ->

	$scope.crearTodosLosUsuarios = ()->
		Restangular.one('perfiles/creartodoslosusuarios').customPUT().then((r)->
			console.log 'Usuarios creados, ', r
			$scope.toastr.success 'Usuarios creados con éxito'
		, (r2)->
			console.log 'No se pudo crear los usuarios, ', r2
			$scope.toastr.error 'No se pudo crear los usuarios', 'Problema'
		)

])