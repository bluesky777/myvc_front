'use strict'

angular.module('myvcFrontApp')
.controller('YearsCtrl', ['App', '$scope', '$http', '$uibModal', '$state', 'ProfesoresServ', '$cookies', '$rootScope', '$filter', 'toastr', 
	(App, $scope, $http, $modal, $state, ProfesoresServ, $cookies, $rootScope, $filter, toastr) ->

		#$scope.config = {alumnos_can_see_notas: $scope.USER.alumnos_can_see_notas}
		$scope.perfilPath = App.images + 'perfil/'

		$http.get('::years/colegio').then((r)->
			r 						= r.data
			$scope.years 			= r.years
			$scope.certificados 	= r.certificados
			$scope.imagenes 		= r.imagenes

			ProfesoresServ.contratos().then((r)->
				$scope.profesores = r

				# Arreglamos paneles y selects cuando ya han llegado todos los datos
				$scope.fixControles()

			, (r2)->
				toastr.error 'No se pudo traer los profesores'
			)

			for anio in $scope.years
				for perio in anio.periodos
					perio.fecha_inicio 	= new Date(perio.fecha_inicio)
					perio.fecha_fin 	= new Date(perio.fecha_fin)


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

			$http.put('::years/alumnos-can-see-notas', { can: can, year_id: year_id }).then((r)->
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


		
		$scope.actualPeriodo = (year, periodo)->

			$http.put('::periodos/establecer-actual/'+periodo.id).then((r)->
				toastr.success 'Periodo ' + periodo.numero + ' establecido como actual.'
				for peri in year.periodos
					peri.actual = false
				periodo.actual = true

			, (r2)->
				toastr.warning 'No se pudo establecer como actual.', 'Problema'
			)



		$scope.crearNewYear = ()->

			$http.post('::years/store', $scope.newYear).then((r)->
				toastr.success 'Año ' + $scope.newYear.year + ' creado. Por favor configúrelo.'
				$scope.nonuevo = false

				for year in $scope.years
					year.actual = 0

				$scope.years.push r.data
			, (r2)->
				toastr.warning 'No se pudo crear año.', 'Problema'
			)


		$scope.guardar_cambios = (year)->
			year.rector_id 			= if year['rector'] then year['rector'].profesor_id else null
			year.secretario_id 		= if year['secretario'] then year['secretario'].profesor_id else null
			year.tesorero_id 		= if year['tesorero'] then year['tesorero'].profesor_id else null

			$http.put('::years/guardar-cambios', year).then((r)->
				toastr.success 'Cambios guardados.'
			, (r2)->
				toastr.warning 'No se pudo guardar cambios.', 'Problema'
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

		$scope.cambiarFechaInicio = (periodo, fecha)->
			$http.put('::periodos/cambiar-fecha-inicio', {periodo_id: periodo.id, fecha: fecha }).then((r)->
				toastr.success 'Fecha guardada.'
			, (r2)->
				toastr.warning 'No se pudo guardar fecha.', 'Problema'
			)
			
		$scope.cambiarFechaFin = (periodo, fecha)->
			$http.put('::periodos/cambiar-fecha-fin', {periodo_id: periodo.id, fecha: fecha }).then((r)->
				toastr.success 'Fecha guardada.'
			, (r2)->
				toastr.warning 'No se pudo guardar fecha.', 'Problema'
			)

		$scope.toggleProfesPuedenEditarNotas = (periodo, pueden)->
			$http.put('::periodos/toggle-profes-pueden-editar-notas', {periodo_id: periodo.id, pueden: pueden }).then((r)->
				toastr.success 'Cambiado.'
			, (r2)->
				toastr.warning 'No se pudo guardar fecha.', 'Problema'
			)

		$scope.toggleProfesPuedenNivelar = (periodo, pueden)->
			$http.put('::periodos/toggle-profes-pueden-nivelar', {periodo_id: periodo.id, pueden: pueden }).then((r)->
				toastr.success 'Cambiado.'
			, (r2)->
				toastr.warning 'No se pudo guardar fecha.', 'Problema'
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
			$modalInstance.close(r.data)
		, (r2)->
			toastr.warning 'No se pudo crear el periodo.', 'Problema'
			$modalInstance.dismiss()
		)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
