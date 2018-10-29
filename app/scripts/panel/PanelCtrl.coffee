'use strict'

angular.module('myvcFrontApp')

.controller('PanelCtrl', ['$scope', '$http', '$state', '$cookies', '$rootScope', 'AuthService', 'Perfil', 'App', 'resolved_user', 'toastr', 'cfpLoadingBar', '$window', '$uibModal',
	($scope, $http, $state, $cookies, $rootScope, AuthService, Perfil, App, resolved_user, toastr, cfpLoadingBar, $window, $modal) ->

		$scope.USER = resolved_user
		$scope.pageTitle = $rootScope.pageTitle
		#$scope.bigLoader = true
		$scope.perfilPath = App.images+'perfil/'
		$scope.views 			= App.views




		# Si el colegio quiere que aparezca su imagen en el encabezado, puede hacerlo.
		$scope.logoPathDefault = 'images/Logo_MyVc_Header.gif'
		$scope.logoPath = 'images/Logo_Colegio_Header.gif'
		#$scope.paramuser = {'username': Perfil.User().username }


		$http.get($scope.logoPath).then(()->
			console.log 'logoPath  existe'
		, ()->
			#console.log 'logoPath NO existe'
			$scope.logoPath = $scope.logoPathDefault # set default image
		)

		$rootScope.menucompacto = if localStorage.menucompacto == 'true' then true else false

		# Para evitar una supuesta espera infinita
		cfpLoadingBar.complete()


		AuthService.verificar_acceso()


		$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)


		$scope.date = new Date();


		$http.get('::years').then((r)->
			$scope.years = r.data
		, (r)->
			toastr.error 'No se trajeron los años'
		)

		$http.get('::periodos').then((r)->
			$scope.periodos = r.data
		, (r)->
			toastr.error 'No se trajeron los periodos'
		)


		if $scope.USER.tipo == 'Acudiente'
			$http.put('::acudientes/mis-acudidos').then((r)->
				$scope.mis_acudidos = r.data.alumnos
			, (r)->
				toastr.error 'No se trajeron los acudidos'
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
			localStorage.menucompacto = $rootScope.menucompacto

		$scope.seeDropdownPeriodos = false

		$scope.togglePeriodos = ()->
			$scope.seeDropdownPeriodos = !$scope.seeDropdownPeriodos
			console.log $scope.seeDropdownPeriodos


		$scope.cambiarPeriodo = (periodo)->

			$http.put('::periodos/useractive/'+periodo.id).then((r)->
				toastr.success 'Periodo cambiado con éxito al perido ' + periodo.numero, 'Cambiado'
				$scope.USER.periodo_id = periodo.id
				$scope.USER.numero_periodo = periodo.numero

				#$rootScope.reload()
				$window.location.reload() # Actualizamos toda la página al cambiar el periodo

			, (r2)->
				toastr.warning 'No se pudo cambiar de periodo.', 'Problema'
			)


		$scope.cambiarYear = (year)->

			$http.put('::years/useractive/'+year.id).then((r)->
				r = r.data
				$scope.USER.year_id = year.id
				$scope.USER.year = year.year
				$scope.USER.numero_periodo = r.numero
				$scope.USER.periodo_id = r.id

				toastr.success 'Año cambiado con éxito: ' + year.year, 'Cambiado'

				$window.location.reload() # Actualizamos toda la página al cambiar el año
				# $rootScope.reload() # No funciona correctamente

			, (r2)->
				toastr.warning 'No se pudo cambiar el año.', 'Problema'
			)

		$scope.logout = ->
			AuthService.logout();

		$scope.goFileManager = ()->
			$state.go 'panel.filemanager'


		$scope.indexChar = (index)->
			return String.fromCharCode(65 + index)


		$scope.verPoliticasPrivacidad = ()->
			modalInstance = $modal.open({
				templateUrl: '==panel/politicasPrivacidadModal.tpl.html'
				controller: 'PoliticasPrivacidadCtrl'
				size: 'lg'
			})

		$scope.$on 'cambianImgs', (event, data)->
			$scope.USER = Perfil.User()
			$scope.setImagenPrincipal()


		return
	]
)

.controller('PoliticasPrivacidadCtrl', ['$scope', '$uibModalInstance', '$http', 'toastr', 'App', ($scope, $modalInstance, $http, toastr, App)->

	$scope.perfilPath 	= App.images+'perfil/'

	$scope.ok = ()->
		$modalInstance.close(alumno)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
