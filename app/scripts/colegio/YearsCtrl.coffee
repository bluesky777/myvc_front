'use strict'

angular.module('myvcFrontApp')
.controller('YearsCtrl', ['App', '$scope', '$http', 'Restangular', '$modal', '$state', 'ProfesoresServ', '$cookies', '$rootScope', 'RYears', '$filter', 'toastr', 
	(App, $scope, $http, Restangular, $modal, $state, ProfesoresServ, $cookies, $rootScope, RYears, $filter, toastr) ->

		if $scope.USER.alumnos_can_see_notas == 1
			$scope.USER.alumnos_can_see_notas = true
		if $scope.USER.alumnos_can_see_notas == 0
			$scope.USER.alumnos_can_see_notas = false

		$scope.config = {alumnos_can_see_notas: $scope.USER.alumnos_can_see_notas}
		$scope.perfilPath = App.images + 'perfil/'

		Restangular.one('years/colegio').customGET().then((r)->
			$scope.years = r.years
			$scope.certificados = r.certificados
			$scope.imagenes = r.imagenes

			ProfesoresServ.contratos().then((r)->
				$scope.profesores = r
			, (r2)->
				console.log 'No se pudo traer los profesores: ', r2
			)


			$scope.fixControles()
		, (r)->
			console.log 'No se trajeron los años'
		)


		$scope.fixControles = ()->
			ultimo = $scope.years.length-1

			$scope.newcertif = {}
			$scope.newYear = {
				nombre_colegio:			$scope.years[ultimo].nombre_colegio
				abrev_colegio:			$scope.years[ultimo].abrev_colegio
				year: 					$scope.years[ultimo].year + 1
				actual:					true
				alumnos_can_see_notas:	true
				nota_minima_aceptada:	$scope.years[ultimo].nota_minima_aceptada
				resolucion:				$scope.years[ultimo].resolucion
				codigo_dane:			$scope.years[ultimo].codigo_dane
				telefono:				$scope.years[ultimo].telefono
				celular:				$scope.years[ultimo].celular
				unidad_displayname:		$scope.years[ultimo].unidad_displayname
				unidades_displayname:	$scope.years[ultimo].unidades_displayname
				genero_unidad:			$scope.years[ultimo].genero_unidad
				subunidad_displayname:	$scope.years[ultimo].subunidad_displayname
				subunidades_displayname:$scope.years[ultimo].subunidades_displayname
				genero_subunidad:		$scope.years[ultimo].genero_subunidad
			}
			

		
		$scope.addPeriodo = (year)->

			modalInstance = $modal.open({
			templateUrl: App.views + 'colegio/addPeriodo.tpl.html'
			controller: 'AddPeriodoCtrl'
			resolve: 
				year: ()->
					year
			})
			modalInstance.result.then( (periodo)->
				year.periodos.push periodo
			)

		
		
		$scope.removePeriodo = (year, periodo)->

			modalInstance = $modal.open({
			templateUrl: App.views + 'colegio/removePeriodo.tpl.html'
			controller: 'RemovePeriodoCtrl'
			resolve: 
				periodo: ()->
					periodo
			})
			modalInstance.result.then( (periodo)->
				year.periodos = $filter('filter')(year.periodos, {id: '!'+periodo.id})
			)


		$scope.toggleBloquearNotas = ()->

			boleano = 0

			if $scope.config.alumnos_can_see_notas == true
				boleano = 1

			Restangular.one('years/alumnos-can-see-notas', boleano).customPUT().then((r)->
				toastr.success r
			, (r2)->
				toastr.warning 'No se pudo bloquear o desblequear el sistema.', 'Problema'
				console.log 'No se pudo bloquear o desblequear el sistema: ', r2
			)


		$scope.restarNewYear = ()->
			if $scope.newYear.year > 1990
				$scope.newYear.year = $scope.newYear.year - 1
		$scope.sumarNewYear = ()->
			if $scope.newYear.year < 3000
				$scope.newYear.year = $scope.newYear.year + 1



		$scope.restarNewNota = ()->
			if $scope.newYear.nota_minima_aceptada > 0
				$scope.newYear.nota_minima_aceptada = $scope.newYear.nota_minima_aceptada - 0.1
		$scope.sumarNewNota = ()->
			if $scope.newYear.nota_minima_aceptada < 1000
				$scope.newYear.nota_minima_aceptada = $scope.newYear.nota_minima_aceptada + 0.1


		
		$scope.actualPeriodo = (periodo)->

			Restangular.one('periodos/establecer-actual', periodo.id).customPUT().then((r)->
				toastr.success 'Periodo ' + periodo.numero + ' establecido como actual.'
			, (r2)->
				toastr.warning 'No se pudo establecer como actual.', 'Problema'
				console.log 'No se pudo establecer como actual: ', r2
			)



		$scope.crearNewYear = ()->

			Restangular.one('years/store').customPOST($scope.newYear).then((r)->
				toastr.success 'Año ' + $scope.newYear.year + ' creado. Por favor configúrelo.'
			, (r2)->
				toastr.warning 'No se pudo crear año.', 'Problema'
				console.log 'No se pudo crear año: ', r2
			)




		return



	]
)


.controller('RemovePeriodoCtrl', ['$scope', '$modalInstance', 'periodo', 'Restangular', 'toastr', ($scope, $modalInstance, periodo, Restangular, toastr)->
	$scope.periodo = periodo

	$scope.ok = ()->

		Restangular.all('periodos/destroy/'+periodo.id).remove().then((r)->
			toastr.success 'Priodo eliminado con éxito.', 'Eliminado'
			$modalInstance.close(periodo)
		, (r2)->
			toastr.warning 'No se pudo eliminar el periodo.', 'Problema'
			console.log 'Error eliminando periodo: ', r2
			$modalInstance.dismiss()
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('AddPeriodoCtrl', ['$scope', '$modalInstance', 'year', 'Restangular', 'toastr', ($scope, $modalInstance, year, Restangular, toastr)->
	$scope.year = year

	$scope.new_periodo = {}
	$scope.year_id = $scope.year.id


	$scope.ok = ()->

		Restangular.one('periodos/store', year.id).customPOST($scope.new_periodo).then((r)->
			toastr.success 'Periodo creado con éxito.', 'Creado'
			$modalInstance.close($scope.new_periodo)
		, (r2)->
			toastr.warning 'No se pudo crear el periodo.', 'Problema'
			console.log 'Error creando periodo: ', r2
			$modalInstance.dismiss()
		)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
