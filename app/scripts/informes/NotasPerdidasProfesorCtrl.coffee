angular.module('myvcFrontApp')

.controller('NotasPerdidasProfesorCtrl',['$scope', 'App', 'Perfil', 'grupos', '$state', '$stateParams', ($scope, App, Perfil, grupos, $state, $stateParams)->
	$scope.grupos             = grupos.data
	$scope.periodo_a_calcular = $stateParams.periodo_a_calcular

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.perfilPath = App.images+'perfil/'

	$scope.$emit 'cambia_descripcion', 'Notas pendientes '

])



.controller('NotasPerdidasTodosCtrl',['$scope', 'App', 'Perfil', 'profesores', '$state', '$stateParams', ($scope, App, Perfil, profesores, $state, $stateParams)->
	$scope.profesores         = profesores.data
	$scope.periodo_a_calcular = $stateParams.periodo_a_calcular

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.perfilPath = App.images+'perfil/'

	$scope.$emit 'cambia_descripcion', 'Notas pendientes '

])




.controller('VerAusenciasCtrl',['$scope', 'App', 'Perfil', 'grupos_ausencias', '$state', ($scope, App, Perfil, grupos_ausencias, $state)->
	$scope.grupos_ausencias = grupos_ausencias.data

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'



	$scope.$emit 'cambia_descripcion', 'Ausencias y tardanzas a la institución '

])





.controller('VerSimatCtrl',['$scope', 'App', 'Perfil', 'grupos_simat', '$state', ($scope, App, Perfil, grupos_simat, $state)->
	$scope.grupos_simat = grupos_simat.data

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'



	$scope.$emit 'cambia_descripcion', 'Ausencias y tardanzas a la institución '

])





.controller('VerObservadorVerticalCtrl',['$scope', 'App', 'Perfil', 'grupos_observador', '$state', ($scope, App, Perfil, grupos_observador, $state)->
	$scope.grupos_observador = grupos_observador.data

	$scope.editor_options =
		allowedContent: true,
		entities: false


	$scope.onEditorReady = ()->
		console.log 'Editor listo'

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'


	$scope.$emit 'cambia_descripcion', 'Observador del alumno '

])



.controller('PlanillasAusenciasAcudientesCtrl',['$scope', 'App', 'Perfil', 'grupos_acud', '$state', ($scope, App, Perfil, grupos_acud, $state)->
	$scope.grupos_acud  = grupos_acud.data.grupos_acud
	$scope.year         = grupos_acud.data.year

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'


	for grup in $scope.grupos_acud
		grup.alumnos_temp = grup.alumnos

		if grup.alumnos_temp.length < 24
			grup.alumnos1 = grup.alumnos_temp

		else if grup.alumnos_temp.length < 50
			grup.alumnos1 = grup.alumnos_temp.splice(0, 23)
			grup.alumnos2 = grup.alumnos_temp.splice(0, 27)

		else if asign.alumnos_temp.length < 75
			grup.alumnos1 = grup.alumnos_temp.splice(0, 23)
			grup.alumnos2 = grup.alumnos_temp.splice(0, 27)
			grup.alumnos3 = grup.alumnos_temp.splice(0, 27)




	$scope.$emit 'cambia_descripcion', 'Planilla de asistencia de padres '

])


.controller('CumpleanosPorMesesCtrl',['$scope', 'App', 'Perfil', 'meses_cumple', '$state', ($scope, App, Perfil, meses_cumple, $state)->
	$scope.meses_cumple = meses_cumple.data

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'


	$scope.$emit 'cambia_descripcion', 'Cumpleaños por meses '

])







.directive('compile', ($compile, $timeout)->
	return {
		restrict: 'A',
		link: (scope,elem,attrs)->
			$timeout(()->
				$compile(elem.contents())(scope);
			);
	}
)




.directive "draggable", ($document) ->
	(scope, element, attr) ->
		[x, y, container, startX, startY] = [null, null, null, null, null]

		# Prevent default dragging of selected content

		mousemove = (event) ->
			y = event.pageY - startY
			x = event.pageX - startX
			#console.log "x: " + x + " y: " + y
			if x < 0 then x = 0
			if y < 0 then y = 0
			scope.$apply( ->
				scope.$parent.events.push mousemove: x: x, y: y, pageX: event.pageX, pageY: event.pageY, startY: startY, startX: startX
				)
			#console.log "#{event.pageX}  #{event.pageY} "
			container.css
				top: y + "px"
				left: x + "px"

		mouseup = ->
			$document.unbind "mousemove", mousemove
			$document.unbind "mouseup", mouseup
			#debugger
			scope.elem.top = y
			scope.elem.left = x
			console.log element

			scope.$apply( ->
				scope.$parent.events.push mouseup: x: x, y: y
				)

		startX = 0
		startY = 0
		x = scope.elem.left
		y = scope.elem.top
		container = null

		element.css
			position: "relative"
			cursor: "pointer"

		element.on "mousedown", (event) ->
			return unless event.which == 1
			event.preventDefault()
			console.log 'mousedown'
			console.log event
			console.log element
			container = attr.$$element.parent()
			console.log container
			scope.$apply( ->
				scope.$parent.events = ["mousedown": x: x, y: y, pageX: event.pageX, pageY: event.pageY, startY: startY, startX: startX]
				)
			startX = event.pageX - x
			startY = event.pageY - y

			$document.on "mousemove", mousemove
			$document.on "mouseup", mouseup
