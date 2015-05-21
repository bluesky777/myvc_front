'use strict'

angular.module('myvcFrontApp')

.controller('PanelCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'AuthService', 'Perfil', 'App', 'resolved_user', 'RYears', 'RPeriodos', 'toastr', 
	($scope, $http, Restangular, $state, $cookies, $rootScope, AuthService, Perfil, App, resolved_user, RYears, RPeriodos, toastr) ->

		$scope.USER = resolved_user
		$scope.pageTitle = $rootScope.pageTitle
		$scope.logoPath = 'images/MyVc-1.gif'
		#$scope.paramuser = {'username': Perfil.User().username }

		$scope.verificar_acceso()



		$scope.date = new Date();

		RYears.getList().then((r)->
			$scope.years = r
		, (r)->
			console.log 'No se trajeron los años'
		)

		RPeriodos.getList().then((r)->
			$scope.periodos = r
		, (r)->
			console.log 'No se trajeron los periodos'
		)


		$scope.setImagenPrincipal = ()->
			ini = App.images+'perfil/'

			imgUsuario = $scope.USER.imagen_nombre
			imgOficial = $scope.USER.foto_nombre
			
			pathUsu = ini + imgUsuario
			pathOfi = ini + imgOficial
			
			$scope.imagenPrincipal = pathUsu
			$scope.imagenOficial = pathOfi

		$scope.setImagenPrincipal()
		
		
		$scope.nameToShow = Perfil.nameToShow

		$scope.usuario = ()->
			return Perfil.User().username

		$scope.toggleCompactMenu = ()->
			$rootScope.menucompacto = !$rootScope.menucompacto

		$scope.seeDropdownPeriodos = false

		$scope.togglePeriodos = ()->
			$scope.seeDropdownPeriodos = !$scope.seeDropdownPeriodos
			console.log $scope.seeDropdownPeriodos
		

		$scope.cambiarPeriodo = (periodo)->
			console.log 'Voy a cambiar de periodo'

			Restangular.one('periodos/useractive', periodo.id).put().then((r)->
				toastr.success 'Periodo cambiado con éxito al perido ' + periodo.numero, 'Cambiado' 
				$scope.USER.periodo_id = periodo.id
				$scope.USER.numero_periodo = periodo.numero

				$rootScope.reload()

			, (r2)->
				toastr.warning 'No se pudo cambiar de periodo.', 'Problema'
				console.log 'Error cambiando de periodo: ', r2
			)

		$scope.logout = ->
			AuthService.logout();

		$scope.goFileManager = ()->
			$state.go 'panel.filemanager'

		#console.log Restangular.all('disciplinas').getList()

		$scope.$on 'cambianImgs', (event, data)->
			$scope.USER = Perfil.User()
			$scope.setImagenPrincipal()

		return
	]
)
