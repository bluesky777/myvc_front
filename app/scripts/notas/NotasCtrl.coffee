'use strict'

angular.module('myvcFrontApp')
.controller('NotasCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', 'notas', '$rootScope', '$filter', 'App', 'AuthService', '$timeout', ($scope, toastr, $http, $modal, $state, notas, $rootScope, $filter, App, AuthService, $timeout) ->

	AuthService.verificar_acceso()

	$scope.asignatura = {}
	$scope.asignatura_id = $state.params.asignatura_id
	$scope.datos = {}
	$scope.UNIDAD = $scope.USER.unidad_displayname
	$scope.SUBUNIDAD = $scope.USER.subunidad_displayname
	$scope.UNIDADES = $scope.USER.unidades_displayname
	$scope.SUBUNIDADES = $scope.USER.subunidades_displayname
	$scope.perfilPath = App.images+'perfil/'
	$scope.views = App.views
	$scope.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)

	$scope.asignatura 	= notas[0]
	$scope.alumnos 		= notas[1]
	$scope.unidades 	= notas[2]

	$scope.subunidadesunidas = []




	for unidad in $scope.unidades

		if unidad.subunidades.length == 0
			$scope.subunidadesunidas.push {empty: true}

		for subunidad in unidad.subunidades
			$scope.subunidadesunidas.push subunidad



	$scope.traerSubunidad = (unidad)->



	$scope.cambiaNota = (nota, otra)->
		$http.put('::notas/update/'+nota.id, {nota: nota.nota}).then((r)->
			toastr.success 'Cambiada: ' + nota.nota
		, (r2)->
			toastr.error 'No pudimos guardar la nota ' + nota.nota
		)


	$scope.showFrases = (alumno)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'notas/showFrases.tpl.html'
			controller: 'ShowFrasesCtrl'
			size: 'lg'
			resolve: 
				alumno: ()->
					alumno
				frases: ()->
					$http.all('frases').getList()
				asignatura: ()->
					$scope.asignatura
		})
		modalInstance.result.then( (alum)->
			#console.log 'Resultado del modal: ', alum
		)


	$scope.promedioTotal = (alumno_id)->
		$scope.subunidadesunidas

		acumUni = 0
		for unidad in $scope.unidades

			porcUni = unidad.porcentaje
			acumSub = 0

			for subunidad in unidad.subunidades

				porcSub = subunidad.porcentaje
				#console.log subunidad.notas, alumno_id, $filter('filter')(subunidad.notas, {'alumno_id': alumno_id})[0]
				
				notaTemp = $filter('filter')(subunidad.notas, {'alumno_id': alumno_id})[0]
				valorNota = parseInt(notaTemp.nota) * parseInt(porcSub) / 100
				acumSub = acumSub + valorNota

			valorUni = acumSub * parseInt(porcUni) / 100
			acumUni = acumUni + valorUni

		return $filter('number')(acumUni, 2);


	$scope.verifClickNotaRapida = (notaObject)->

		$timeout(()->
			if $rootScope.notaRapida.enable
				if notaObject.backup
					if $rootScope.notaRapida.valorNota != notaObject.nota
						notaObject.backup = notaObject.nota
						notaObject.nota = $rootScope.notaRapida.valorNota
					else
						temp = notaObject.backup
						notaObject.backup = notaObject.nota
						notaObject.nota = temp
				else
					notaObject.backup = notaObject.nota
					notaObject.nota = $rootScope.notaRapida.valorNota
		
				$scope.cambiaNota(notaObject)
			
		)
		return

	return
])


.controller('ShowFrasesCtrl', ['$scope', '$uibModalInstance', 'alumno', 'frases', 'asignatura', '$http', 'toastr', '$filter', ($scope, $modalInstance, alumno, frases, asignatura, $http, toastr, $filter)->
	$scope.alumno = alumno
	$scope.frases = frases
	$scope.asignatura = asignatura

	$scope.alumno.newFrase = ''


	$http.get('::frases_asignatura/show/'+alumno.alumno_id+'/'+asignatura.asignatura_id).then((r)->
		$scope.frases_asignatura = r.data
	, (r2)->
		toastr.warning 'No se pudo traer frases.', 'Problema'
	)
	


	$scope.addFrase = ()->
		
		if $scope.alumno.newFrase != ''
			dato = 
				alumno_id:		alumno.alumno_id
				frase:			$scope.alumno.newFrase
				asignatura_id:	$scope.asignatura.asignatura_id

			$http.post('::frases_asignatura/store', dato).then((r)->
				$scope.frases_asignatura = r.data
				toastr.success 'Frase añadida.'
			, (r2)->
				toastr.warning 'No se pudo añadir frase.', 'Problema'
			)
		else
			toastr.warning 'No ha copiado ninguna frase'


	$scope.addFrase_id = ()->

		if $scope.alumno.newFrase_by_id
			dato = 
				alumno_id:		alumno.alumno_id
				frase_id:		$scope.alumno.newFrase_by_id.id
				asignatura_id:	$scope.asignatura.asignatura_id

			$http.post('::frases_asignatura/store/'+$scope.alumno.newFrase_by_id.id, dato).then((r)->
				toastr.success 'Frase añadida.'
				$scope.frases_asignatura = r.data
			, (r2)->
				toastr.warning 'No se pudo añadir frase.', 'Problema'
			)
		else
			toastr.warning 'No ha seleccionado frase'


	$scope.quitarFrase = (fraseasig)->
		$http.delete('::frases_asignatura/destroy/'+fraseasig.id).then((r)->
			toastr.success 'Frase quitada'
			$scope.frases_asignatura = $filter('filter')($scope.frases_asignatura, {id: '!'+fraseasig.id})
		, (r2)->
			toastr.warning 'No se pudo quitar la frase.', 'Problema'
		)


	$scope.ok = ()->
		$modalInstance.close(alumno)


])



