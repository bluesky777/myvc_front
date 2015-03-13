angular.module('myvcFrontApp')

.directive('notaRapida',['App', '$rootScope', 'Restangular', 'toastr', (App, $rootScope, Restangular, toastr)-> 

	restrict: 'AE'
	transclude: true,
	templateUrl: "#{App.views}directives/notaRapida.tpl.html"
	#scope: 
	#	ngModel: "="
	#require: 'ngModel'

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if
		
		scope.valorNotaRapida = 100
		scope.activado = false

		scope.activar = ()->
			if !scope.activado
				scope.activado = true
				$rootScope.notaRapida.enable = scope.activado
				toastr.info 'Nota rápida activada', 'ACTIVADA'

		scope.desactivar = ()->
			scope.activado = false
			$rootScope.notaRapida.enable = scope.activado
			toastr.info 'Nota rápida desactivada', 'DESACTIVADA'


		scope.$on('keydown:27', (onEvent, keydownEvent)->
			scope.desactivar()
		)

		Restangular.all('escalas').getList().then((r)->
			scope.escalas = r
		, (r2)->
			console.log 'No se trajeron las escalas valorativas', r2
		)

		scope.setValor = (n)->
			$rootScope.notaRapida.valorNota = n
			scope.activar()

])

.directive('cambiamodel', ['$rootScope', ($rootScope)->

	restrict: 'A',
	link: (scope, element, attrs)->
		scope.$watch(attrs.ngModel, (v)->
			$rootScope.notaRapida.valorNota = v
		)
])

.directive('keypressEvents', ['$document','$rootScope',($document, $rootScope)->
	restrict: 'A',
	link: ()->
		$document.bind('keypress keydown', (e)->
			#$rootScope.$broadcast('keypress', e)
			if e.which == 27
				$rootScope.$broadcast('keydown:27', e)

		)
])

.filter('range', ()->
	(input, inicial, total)->
		total = parseInt(total)
		inicial = parseInt(inicial)

		for i in [inicial..total]
			input.push(i);
		return input
)

.directive('draggable', [ ()->
	restrict: 'AE'
	transclude: true
	replace: true
	scope: {}
	templateUrl: (el, attrs) ->
		if angular.isDefined(attrs.template) then attrs.template else '/tmpls/draggable-default'
	link: (scope, el, attrs) ->


		# draggable object properties
		scope.obj =
			id: null
			content: ''
			group: null
		scope.placeholder = false
		scope.obj.content = el.html()
		if angular.isDefined(attrs.id)
			scope.obj.id = attrs.id
		if angular.isDefined(attrs.placeholder)
			scope.placeholder = scope.$eval(attrs.placeholder)
		# options for jQuery UI's draggable method
		opts = if angular.isDefined(attrs.options) then scope.$eval(attrs.options) else {}
		if angular.isDefined(attrs.group)
			scope.obj.group = attrs.group
			opts.stack = '.' + attrs.group
		# event handlers
		evts = 
			start: (evt, ui) ->
				if scope.placeholder
					ui.helper.wrap '<div class="dragging"></div>'
				scope.$apply ->
					# emit event in angular context
					scope.$emit 'draggable.started', obj: scope.obj
					return
				# end $apply
				return
			drag: (evt) ->
				scope.$apply ->
					# emit event in angular context
					scope.$emit 'draggable.dragging'
					return
				# end $apply
				return
			stop: (evt, ui) ->
				if scope.placeholder
					ui.helper.unwrap()
				scope.$apply ->
				# emit event in angular context
					scope.$emit 'draggable.stopped'
					return
				# end $apply
				return
			# end evts
		# combine options and events
		options = angular.extend({}, opts, evts)
		el.draggable options
		# make element draggable
])

.run(['$templateCache', ($templateCache)->
	$templateCache.put('/tmpls/draggable-default','<div ng-transclude></div>');
])


###
.directive('keypressListen', ['$rootScope', ($rootScope)->
	restrict: 'A',
	link: (scope, el, attrs)->
		# For listening to a keypress event with a specific code
		scope.$on('keypress:13', (onEvent, keypressEvent)->
			console.log 'Enter presionado'
		)
		# For listening to all keypress events
		scope.$on('keypress', (onEvent, keypressEvent)->
			if (keypressEvent.which == 120)
				console.log 'X presionada'
			else
				console.log 'Keycode: ' + keypressEvent.which
		)

]);
###