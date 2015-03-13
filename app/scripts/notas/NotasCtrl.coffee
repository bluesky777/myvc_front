'use strict'

angular.module('myvcFrontApp')
.controller('NotasCtrl', ['$scope', 'toastr', 'Restangular', '$modal', '$state', 'notas', '$rootScope', '$filter', 'App', 'AuthService', '$timeout', ($scope, toastr, Restangular, $modal, $state, notas, $rootScope, $filter, App, AuthService, $timeout) ->

	AuthService.verificar_acceso()

	$scope.asignatura = {}
	$scope.asignatura_id = $state.params.asignatura_id
	$scope.datos = {}
	$scope.UNIDAD = $scope.USER.unidad_displayname
	$scope.SUBUNIDAD = $scope.USER.subunidad_displayname
	$scope.UNIDADES = $scope.USER.unidades_displayname
	$scope.SUBUNIDADES = $scope.USER.subunidades_displayname
	$scope.perfilPath = App.images+'perfil/'

	$scope.asignatura 	= notas[0]
	$scope.alumnos 		= notas[1]
	$scope.unidades 	= notas[2]

	$scope.subunidadesunidas = []




	for unidad in $scope.unidades

		if unidad.subunidades.length == 0
			$scope.subunidadesunidas.push {empty: true}

		for subunidad in unidad.subunidades
			$scope.subunidadesunidas.push subunidad

	console.log '$scope.subunidadesunidas ', $scope.subunidadesunidas


	$scope.traerSubunidad = (unidad)->



	$scope.cambiaNota = (nota)->
		Restangular.one('notas/update', nota.id).customPUT({nota: nota.nota}).then((r)->
			toastr.success 'Cambiada: ' + nota.nota
			console.log 'Cuando la nota cambia, el objeto nota: ', nota
		, (r2)->
			console.log 'No pudimos guardar la nota ', nota
			toastr.error 'No pudimos guardar la nota ' + nota.nota
		)


	$scope.showFrases = (alumno)->
		console.log 'Presionado para eliminar fila: ', alumno

		modalInstance = $modal.open({
			templateUrl: App.views + 'notas/showFrases.tpl.html'
			controller: 'ShowFrasesCtrl'
			size: 'lg'
			resolve: 
				alumno: ()->
					alumno
				frases: ()->
					Restangular.all('frases').getList()
				asignatura: ()->
					$scope.asignatura
		})
		modalInstance.result.then( (alum)->
			console.log 'Resultado del modal: ', alum
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
		console.log notaObject

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


	#console.log Restangular.all('disciplinas').getList()
	return
])


.controller('ShowFrasesCtrl', ['$scope', '$modalInstance', 'alumno', 'frases', 'asignatura', 'Restangular', 'toastr', '$filter', ($scope, $modalInstance, alumno, frases, asignatura, Restangular, toastr, $filter)->
	$scope.alumno = alumno
	$scope.frases = frases
	$scope.asignatura = asignatura

	$scope.alumno.newFrase = ''

	console.log alumno

	Restangular.all('frases_asignatura/show/'+alumno.alumno_id+'/'+asignatura.asignatura_id).getList().then((r)->
		$scope.frases_asignatura = r
	, (r2)->
		toastr.warning 'No se pudo traer frases.', 'Problema'
		console.log 'Error añadiendo frase: ', r2
	)
	


	$scope.addFrase = ()->
		
		if $scope.alumno.newFrase != ''
			dato = 
				alumno_id:		alumno.alumno_id
				frase:			$scope.alumno.newFrase
				asignatura_id:	$scope.asignatura.asignatura_id

			Restangular.all('frases_asignatura/store').customPOST(dato).then((r)->
				toastr.success 'Frase añadida.'
				$scope.frases_asignatura = r
			, (r2)->
				toastr.warning 'No se pudo añadir frase.', 'Problema'
				console.log 'Error añadiendo frase: ', r2
			)
		else
			console.log 'No ha copiado ninguna frase'
			toastr.warning 'No ha copiado ninguna frase'


	$scope.addFrase_id = ()->

		if $scope.alumno.newFrase_by_id
			dato = 
				alumno_id:		alumno.alumno_id
				frase_id:		$scope.alumno.newFrase_by_id.id
				asignatura_id:	$scope.asignatura.asignatura_id

			Restangular.all('frases_asignatura/store/'+$scope.alumno.newFrase_by_id.id).customPOST(dato).then((r)->
				toastr.success 'Frase añadida.'
				$scope.frases_asignatura = r
			, (r2)->
				toastr.warning 'No se pudo añadir frase.', 'Problema'
				console.log 'Error añadiendo frase: ', r2
			)
		else
			console.log 'No ha seleccionado frase'
			toastr.warning 'No ha seleccionado frase'


	$scope.quitarFrase = (fraseasig)->
		Restangular.all('frases_asignatura/destroy/'+fraseasig.id).remove().then((r)->
			toastr.success 'Frase quitada'
			$scope.frases_asignatura = $filter('filter')($scope.frases_asignatura, {id: '!'+fraseasig.id})
		, (r2)->
			toastr.warning 'No se pudo quitar la frase.', 'Problema'
			console.log 'Error quitando frase: ', r2
		)


	$scope.ok = ()->
		$modalInstance.close(alumno)


])



