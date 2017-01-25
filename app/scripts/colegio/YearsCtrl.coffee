'use strict'

angular.module('myvcFrontApp')
.controller('YearsCtrl', ['App', '$scope', '$http', '$uibModal', '$state', 'ProfesoresServ', '$cookies', '$rootScope', '$filter', 'toastr', 
	(App, $scope, $http, $modal, $state, ProfesoresServ, $cookies, $rootScope, $filter, toastr) ->

		if $scope.USER.alumnos_can_see_notas == 1
			$scope.USER.alumnos_can_see_notas = true
		if $scope.USER.alumnos_can_see_notas == 0
			$scope.USER.alumnos_can_see_notas = false

		$scope.config = {alumnos_can_see_notas: $scope.USER.alumnos_can_see_notas}
		$scope.perfilPath = App.images + 'perfil/'

		$http.get('::years/colegio').then((r)->
			r = r.data
			$scope.years = r.years
			$scope.certificados = r.certificados
			$scope.imagenes = r.imagenes

			ProfesoresServ.contratos().then((r)->
				$scope.profesores = r

				# Arreglamos paneles y selects cuando ya han llegado todos los datos
				$scope.fixControles()

			, (r2)->
				toastr.error 'No se pudo traer los profesores'
			)


		, (r)->
			toastr.error 'No se trajeron los años'
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

			
			for year_cambiar in $scope.years
				# Abramos panel del año actual
				year_cambiar.ocultando = if year_cambiar.actual then false else true

				# Arreglemos los selects
				year_cambiar.rector 	=	$filter('filter')($scope.profesores, profesor_id: year_cambiar.rector_id, true)[0]
				year_cambiar.secretario =	$filter('filter')($scope.profesores, profesor_id: year_cambiar.secretario_id, true)[0]
				year_cambiar.tesorero 	=	$filter('filter')($scope.profesores, profesor_id: year_cambiar.tesorero_id, true)[0]
				


		
		$scope.addPeriodo = (year)->

			modalInstance = $modal.open({
			templateUrl: '==colegio/addPeriodo.tpl.html'
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
			templateUrl: '==colegio/removePeriodo.tpl.html'
			controller: 'RemovePeriodoCtrl'
			resolve: 
				periodo: ()->
					periodo
			})
			modalInstance.result.then( (periodo)->
				year.periodos = $filter('filter')(year.periodos, {id: '!'+periodo.id})
			)


		$scope.toggleBloquearNotas = (year_id, can)->

			boleano = 0
			if can == true
				boleano = 1

			$http.put('::years/alumnos-can-see-notas', { can: boleano, year_id: year_id }).then((r)->
				toastr.success r.data
			, (r2)->
				toastr.warning 'No se pudo bloquear o desblequear el sistema.', 'Problema'
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

			$http.put('::periodos/establecer-actual', periodo.id).then((r)->
				toastr.success 'Periodo ' + periodo.numero + ' establecido como actual.'
			, (r2)->
				toastr.warning 'No se pudo establecer como actual.', 'Problema'
			)



		$scope.crearNewYear = ()->

			$http.post('::years/store', $scope.newYear).then((r)->
				toastr.success 'Año ' + $scope.newYear.year + ' creado. Por favor configúrelo.'
				$scope.years.push r.data
			, (r2)->
				toastr.warning 'No se pudo crear año.', 'Problema'
			)


		$scope.deleteYear = (year)->

			modalInstance = $modal.open({
				templateUrl: '==colegio/removeYear.tpl.html'
				controller: 'RemoveYearCtrl'
				resolve: 
					year: ()->
						year
			})
			modalInstance.result.then( (year)->
				$scope.years = $filter('filter')($scope.years, {id: '!'+year.id})
			)




		return



	]
)


.controller('RemoveYearCtrl', ['$scope', '$uibModalInstance', 'year', '$http', 'toastr', ($scope, $modalInstance, year, $http, toastr)->
	$scope.year = year

	$scope.ok = ()->

		$http.delete('::years/delete/'+year.id).then((r)->
			toastr.success 'Año ' + year.year + ' enviado a la papelera.'
			$modalInstance.close(year)
		, (r2)->
			toastr.warning 'No se pudo eliminar el año.', 'Problema'
			$modalInstance.dismiss()
		)

		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('RemovePeriodoCtrl', ['$scope', '$uibModalInstance', 'periodo', '$http', 'toastr', ($scope, $modalInstance, periodo, $http, toastr)->
	$scope.periodo = periodo

	$scope.ok = ()->

		$http.delete('::periodos/destroy/'+periodo.id).then((r)->
			toastr.success 'Periodo eliminado con éxito.', 'Eliminado'
			$modalInstance.close(periodo)
		, (r2)->
			toastr.warning 'No se pudo eliminar el periodo.', 'Problema'
			$modalInstance.dismiss()
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('AddPeriodoCtrl', ['$scope', '$uibModalInstance', 'year', '$http', 'toastr', ($scope, $modalInstance, year, $http, toastr)->
	$scope.year = year

	$scope.new_periodo = {}
	$scope.year_id = $scope.year.id


	$scope.ok = ()->

		$http.post('::periodos/store/'+year.id, $scope.new_periodo).then((r)->
			toastr.success 'Periodo creado con éxito.', 'Creado'
			$modalInstance.close($scope.new_periodo)
		, (r2)->
			toastr.warning 'No se pudo crear el periodo.', 'Problema'
			$modalInstance.dismiss()
		)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
