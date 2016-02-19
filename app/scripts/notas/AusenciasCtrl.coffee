angular.module('myvcFrontApp')
.controller('AusenciasCtrl', ['$scope', 'toastr', 'Restangular', '$state', '$rootScope', 'ausencias', '$filter', 'App', 'AuthService', '$uibModal', ($scope, toastr, Restangular, $state, $rootScope, ausencias, $filter, App, AuthService, $modal) ->


	AuthService.verificar_acceso()

	$scope.asignatura = {}
	$scope.asignatura_id = $state.params.asignatura_id
	$scope.dato = {}
	$scope.perfilPath = App.images+'perfil/'

	$scope.meses = [
		{nombre: 'Enero'}
		{nombre: 'Febrero'}
		{nombre: 'Marzo'}
		{nombre: 'Abril'}
		{nombre: 'Mayo'}
		{nombre: 'Junio'}
		{nombre: 'Julio'}
		{nombre: 'Agosto'}
		{nombre: 'Septiembre'}
		{nombre: 'Octubre'}
		{nombre: 'Noviembre'}
		{nombre: 'Diciembre'}
	]

	numYearActual = $scope.USER.year
	#$scope.dato.mes = {mes: $filter('date')(new Date, 'M')}
	$scope.dato.mes = '' + new Date().getMonth()
	console.log '$scope.dato.mes', $scope.dato.mes

	DAYS_IN_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	getDaysInMonth = ( year, month )->
		if ((month == 1) and (year % 4 == 0) and ((year % 100 != 0) or (year % 400 == 0)))
			return 29
		else
			return DAYS_IN_MONTH[month]

	getAllDaysInMonth = (month)->
		
		num = getDaysInMonth(numYearActual, month)
		r=[]
		for i in [1..num]
			d = new Date(numYearActual, parseInt($scope.dato.mes), i)
			n = d.getDay()

			if n != 0 and n != 6
				r.push i
			
		return r


	$scope.dias = getAllDaysInMonth($scope.dato.mes)

	$scope.asignatura 	= ausencias[0]
	$scope.alumnos 		= ausencias[1]


	Restangular.one('asignaturas/show/' + $scope.asignatura_id).get().then((r)->
		$scope.asignatura = r
	, (r2)->
		console.log 'No se pudo traer los datos de la asignatura', r2
		toastr.error 'No se pudo traer los datos de la asignatura'
	)


	$scope.mesSelect = ()->
		console.log $scope.dato
		$scope.dias = getAllDaysInMonth(parseInt($scope.dato.mes))


	$scope.hasAusencias = (alumno, dia)->
		
		if alumno.ausencias.length > 0
			
			
			#for ausencia in alumno.ausencias
			#	if ausencia.mes == $scope.dato.mes

			found = $filter('filter')(alumno.ausencias, {mes: parseInt($scope.dato.mes), dia: dia}, true)
			
			if found.length > 0
				return true
			else
				return false
		else
			return false

	$scope.deleteAusencia = (alumno, dia)->
		console.log 'Presionado para elimiar ausencia: ', alumno

		found = $filter('filter')(alumno.ausencias, {mes: parseInt($scope.dato.mes), dia: dia}, true)


		Restangular.one('ausencias/destroy/' + found[0].id).customDELETE().then((r)->
			toastr.success 'Ausencia quitada con éxito.'
			alumno.ausencias = $filter('filter')(alumno.ausencias, {id: '!'+found[0].id})

		, (r2)->
			toastr.warning 'No se pudo quitar la ausencia.', 'Problema'
			console.log 'Error quitando ausencia: ', r2
		)

	$scope.showAddAusencia = (alumno, dia)->
		console.log 'Presionado para agregar ausencia: ', alumno

		dato = 
			asignatura_id: $scope.asignatura_id
			alumno_id: alumno.alumno_id
			cantidad_ausencia: 1
			fecha_hora: new Date(numYearActual, parseInt($scope.dato.mes), dia)

		Restangular.one('ausencias/store').customPOST(dato).then((r)->
			toastr.success 'Ausencia agregada con éxito.'
			r.fecha_hora = new Date(r.fecha_hora)
			r.mes = r.fecha_hora.getMonth()
			r.dia = r.fecha_hora.getDate()
			alumno.ausencias.push r
			console.log 'Agregada ', r
		, (r2)->
			toastr.warning 'No se pudo agregar ausencia.', 'Problema'
			console.log 'Error agregando ausencia: ', r2
		)

		###		
		modalInstance = $modal.open({
			templateUrl: App.views + 'notas/addAusencia.tpl.html'
			controller: 'AddAusenciaCtrl'
			resolve: 
				alumno: ()->
					alumno
				asignatura_id: ()->
					$scope.asignatura_id
		})
		modalInstance.result.then( (alum)->
			console.log 'Resultado del modal: ', alum
		)
		###
	$scope.ausenciasTotales = (alumno)->
		cant = 0
		for aus in alumno.ausencias
			cant = cant + aus.cantidad_ausencia
		return cant


])

.controller('AddAusenciaCtrl', ['$scope', '$uibModalInstance', 'alumno', 'asignatura_id', 'Restangular', 'toastr', ($scope, $modalInstance, alumno, asignatura_id, Restangular, toastr)->
	$scope.alumno = alumno

	$scope.ok = ()->

		dato = 
			asignatura_id: asignatura_id
			alumno_id: alumno.alumno_id
			cantidad_ausencia: 1

		Restangular.one('ausencias/store').customPOST().then((r)->
			toastr.success 'Ausencia agregada con éxito.'
		, (r2)->
			toastr.warning 'No se pudo agregar ausencia.', 'Problema'
			console.log 'Error agregando ausencia: ', r2
		)
		$modalInstance.close(alumno)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])




