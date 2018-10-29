angular.module('myvcFrontApp')

.directive('anunciosDir',['App', '$http', 'toastr', '$uibModal', '$state', 'AuthService', '$sce', '$timeout', (App, $http, toastr, $modal, $state, AuthService, $sce, $timeout)->

	restrict: 'E'
	templateUrl: "#{App.views}panel/anunciosDir.tpl.html"


	link: (scope, iElem, iAttrs)->

		scope.perfilPath      = App.images+'perfil/'
		scope.views 		      = App.views


		if $state.is 'panel'
			$http.get('::ChangesAsked/to-me').then((r)->
				scope.changes_asked = r.data

				# Calendario
				$timeout(()->
					for evento in scope.changes_asked.eventos
						evento.start      = new Date(evento.start);
						evento.end        = if evento.end then new Date(evento.end) else null;
						if evento.solo_profes
							evento.className  = 'evento-solo-profes'
						else
							evento.className  = if evento.cumple_alumno_id or evento.cumple_profe_id then 'evento-cumpleanios' else null

					scope.eventos = [
						scope.changes_asked.eventos
					];

				, 500)

				# Publicaciones
				for publi in scope.changes_asked.publicaciones
					publi.contenido_tr = $sce.trustAsHtml(publi.contenido)

				if scope.changes_asked.mis_publicaciones
					for publi in scope.changes_asked.mis_publicaciones
						publi.contenido_tr = $sce.trustAsHtml(publi.contenido)


				if AuthService.hasRoleOrPerm(['alumno', 'acudiente'])
					scope.publicaciones_actuales   = [ scope.changes_asked.publicaciones[0] ]

					if scope.changes_asked.publicaciones.length > 1
						scope.publicaciones_actuales.push(scope.changes_asked.publicaciones[1])


				if AuthService.hasRoleOrPerm(['admin', 'profesor'])
					if scope.changes_asked.publicaciones.length > 0
						scope.publicacion_actual = scope.changes_asked.publicaciones[0]


				# Gráfico del trabajo de profesores
				if AuthService.hasRoleOrPerm(['admin', 'profesor', 'alumno'])

					scope.options = {
						chart: {
							type: 'discreteBarChart',
							height: 180,
							margin : {
								top: 20,
								right: 20,
								bottom: 60,
								left: 55
							},
							useInteractiveGuideline: true,
							x: (d)-> return d.label;
							y: (d)-> return d.value;
							showValues: true,
							valueFormat: (d)-> d3.format(',.0f')(d);
							transitionDuration: 500
							xAxis: {
								axisLabel: "X Axis",
								rotateLabels: 30,
								showMaxMin: false
							}
							zoom: {
								enabled: true,
								scaleExtent: [1,10],
								useFixedDomain: false,
								useNiceScale: false,
								horizontalOff: false,
								verticalOff: true,
								unzoomEventType: "dblclick.zoom"
							}
						}
						title: {
							enable: false,
							text: 'Asignaturas correctas'
						}
					};


					valores = []
					for profe in scope.changes_asked.profes_actuales
						valores.push { label: profe.nombres + ' ' + profe.apellidos.substr(0,1) + '.', value: profe.porcentaje }


					scope.data = [{
						key: "Asignaturas correctas",
						values: valores
					}];
				# fin de IF AuthService





			, (r2)->
				#toastr.error 'No se pudo traer los anuncios.'
				console.log r2
			)

	controller: 'AnunciosDirCtrl'
])


.directive('publicacionesPanelDir',['App', (App)->

	restrict: 'E'
	templateUrl: "#{App.views}panel/publicacionesPanelDir.tpl.html"

])








.controller('AceptarAskedCtrl', ['$scope', '$uibModalInstance', 'asked', 'tipo', 'valor_nuevo', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, tipo, valor_nuevo, $http, toastr, App)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked


	$scope.aceptarAsignatura = ()->
			datos = { pedido: asked, tipo: tipo, asker_id: asked.asked_by_user_id }

			$http.put('::ChangesAsked/aceptar-asignatura', datos).then((r)->
				$modalInstance.close(r.data)
			, (r2)->
				toastr.warning 'Problema', 'No se pudo aceptar petición.'
			)


	$scope.ok = ()->
		if asked.assignment_id
			$scope.aceptarAsignatura()
		else
			datos = { asked_id: asked.asked_id, data_id: asked.detalles.data_id, tipo: tipo, valor_nuevo: valor_nuevo, asker_id: asked.asked_by_user_id }

			if asked.alumno_id
				datos.alumno_id = asked.alumno_id

			$http.put('::ChangesAsked/aceptar-alumno', datos).then((r)->
				$modalInstance.close(r.data)
			, (r2)->
				toastr.warning 'Problema', 'No se pudo aceptar petición.'
			)



	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')


])




.controller('RechazarAskedCtrl', ['$scope', '$uibModalInstance', 'asked', 'tipo', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, tipo, $http, toastr, App)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked

	$scope.ok = ()->

		data_id       = if asked.detalles then asked.detalles.data_id else asked.assignment_id
		assignment_id = asked.detalles.assignment_id

		datos = { asked_id: asked.asked_id, data_id: data_id, assignment_id: assignment_id, tipo: tipo, asker_id: asked.asked_by_user_id }

		$http.put('::ChangesAsked/rechazar', datos).then((r)->
			$modalInstance.close(r.data)
		, (r2)->
			toastr.error 'Problema', 'No se pudo rechazar petición.'
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


.controller('EliminarAskedCtrl', ['$scope', '$uibModalInstance', 'asked', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, $http, toastr, App)->
	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked

	$scope.ok = ()->

		datos = { asked_id: asked.asked_id, data_id: asked.detalles.data_id }

		$http.put('::ChangesAsked/destruir', datos).then((r)->
			$modalInstance.close(r.data)
		, (r2)->
			toastr.error 'Problema', 'No se pudo eliminar peticiones.'
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


