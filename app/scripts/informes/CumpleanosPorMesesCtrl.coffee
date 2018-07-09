angular.module('myvcFrontApp')

.controller('CumpleanosPorMesesCtrl',['$scope', 'App', 'Perfil', 'meses_cumple', '$state', '$filter', ($scope, App, Perfil, meses_cumple, $state, $filter)->
	$scope.meses_cumple = meses_cumple.data
	$scope.tamanio_letra = 15;

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'
	$scope.alinear = 'center';



	$scope.aumentar_letra = ()->
		$scope.tamanio_letra = $scope.tamanio_letra + 2;
	$scope.disminuir_letra = ()->
		$scope.tamanio_letra = $scope.tamanio_letra - 2;


	$scope.setAlinear = (align)->
		$scope.alinear = align;

	$scope.establecerColumnas = (mes)->
		if mes.apretado == true
			return
		mes.apretado      = true
		mes.alumnos_temp  = mes.alumnos.splice( parseInt(mes.alumnos.length / 2), mes.alumnos.length )



	$scope.setAlinear2 = (align)->
		$scope.alinear2 = align;

	$scope.establecerColumnas2 = (mes)->
		mes.apretado      = false
		mes.alumnos 			= mes.alumnos.concat( mes.alumnos_temp )
		mes.alumnos_temp 	= []


	for mes in $scope.meses_cumple
		for alum in mes.alumnos
			alum.day_nac = alum.fecha_nac.substr(8, 2)

		mes.alumnos       = $filter('orderBy')(mes.alumnos, 'day_nac')

		mes.alumnos_temp  = []



	$scope.quitar_mes = (mes)->
		mes.quitado = true;


	$scope.$emit 'cambia_descripcion', 'Cumpleaños por meses '

])





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
			if scope.elem
				scope.elem.top = y
				scope.elem.left = x


			scope.$apply( ->
				scope.$parent.events.push mouseup: x: x, y: y
				)

		startX = 0
		startY = 0
		if scope.elem
			x = scope.elem.left
			y = scope.elem.top
		container = null

		element.css
			position: "relative"
			cursor: "pointer"

		element.on "mousedown", (event) ->
			return unless event.which == 1
			event.preventDefault()

			container = attr.$$element.parent()

			scope.$apply( ->
				scope.$parent.events = ["mousedown": x: x, y: y, pageX: event.pageX, pageY: event.pageY, startY: startY, startX: startX]
				)
			startX = event.pageX - x
			startY = event.pageY - y

			$document.on "mousemove", mousemove
			$document.on "mouseup", mouseup
