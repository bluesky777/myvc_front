'use strict'

angular.module('myvcFrontApp')

.controller('PanelCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'AuthService', 'Perfil', 'App', 'resolved_user', 'RYears', 'RPeriodos', 'toastr', 'cfpLoadingBar', 
	($scope, $http, Restangular, $state, $cookies, $rootScope, AuthService, Perfil, App, resolved_user, RYears, RPeriodos, toastr, cfpLoadingBar) ->

		$scope.USER = resolved_user
		$scope.pageTitle = $rootScope.pageTitle
		$scope.logoPath = 'images/MyVc-1.gif'
		#$scope.paramuser = {'username': Perfil.User().username }


		# Para evitar una supuesta espera infinita
		cfpLoadingBar.complete()
		

		$scope.verificar_acceso()


		$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)


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


		$scope.cambiarYear = (year)->
			console.log 'Voy a cambiar de año'

			Restangular.one('years/useractive', year.id).put().then((r)->
				toastr.success 'Año cambiado con éxito: ' + year.numero, 'Cambiado' 
				$scope.USER.year_id = year.id
				$scope.USER.year = year.year
				$scope.USER.numero_periodo = r.numero

				$rootScope.reload()

			, (r2)->
				toastr.warning 'No se pudo cambiar el año.', 'Problema'
				console.log 'Error cambiando el año: ', r2
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
