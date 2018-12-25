'use strict'

angular.module("myvcFrontApp")


.controller('TardanzasAusenciasAlumnoAsignModalCtrl', ['$scope', 'App', '$uibModalInstance', 'alumno', '$http', 'toastr', 'EscalasValorativasServ', ($scope, App, $modalInstance, alumno, $http, toastr, EscalasValorativasServ)->
	$scope.datos 				      = {}
	$scope.perfilPath 			  = App.images+'perfil/'
	$scope.alumno             = alumno




	$scope.guardarCambioAusencia = (ausencia)->
		datos =
			ausencia_id: ausencia.id
			fecha_hora: $filter('date')(ausencia.fecha_hora, 'yyyy-MM-dd HH:mm:ss')

		$http.put('::ausencias/guardar-cambios-ausencia', datos).then((r)->
			r 		= r.data
			#r.fecha_hora = new Date(r.fecha_hora)
			alumno.tardanzas.push r
		, (r2)->
			toastr.warning 'No se pudo agregar tardanza.', 'Problema'
		)



	$scope.eliminarAusencia = (ausencia, alumno_aus_tard_edit)->
		$http.delete('::ausencias/destroy/' + ausencia.id).then((r)->
			r 		= r.data
			alumno_aus_tard_edit.ausencias = $filter('filter')(alumno_aus_tard_edit.ausencias, { id: '!'+r.id })
			ausencia.isOpen = false
		, (r2)->
			toastr.warning 'No se pudo quitar ausencia.', 'Problema'
		)

	$scope.eliminarTardanza = (tardanza, alumno_aus_tard_edit)->
		$http.delete('::ausencias/destroy/' + tardanza.id).then((r)->
			r 		= r.data
			alumno_aus_tard_edit.tardanzas = $filter('filter')(alumno_aus_tard_edit.tardanzas, { id: '!'+r.id })
			tardanza.isOpen = false
		, (r2)->
			toastr.warning 'No se pudo quitar tardanza.', 'Problema'
		)








	$scope.ok = ()->
		$modalInstance.close()


])




